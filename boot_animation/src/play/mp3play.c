#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <alsa/asoundlib.h>

#include <mad.h>

static int decode(unsigned char const *, unsigned long);

int 			set_pcm();
snd_pcm_t*		handle=NULL;
snd_pcm_hw_params_t*	params=NULL;

int main(int argc, char *argv[])
{
    struct stat stat;
    void *fdm;

    if (argc != 2)
    {
        printf("Usage: play <file.mp3>\n");
        return 1;
    }

    int fd;
    fd = open(argv[1], O_RDONLY);

    if(fd < 0)
    {
        perror("Error: failed to open file - ");
        return 1;
    }

    if (fstat(fd, &stat) == -1 ||stat.st_size == 0)
    {
        printf("Error: stat failure - ");
        return 2;
    }

    fdm = mmap(0, stat.st_size, PROT_READ, MAP_SHARED, fd, 0);

    if (fdm == MAP_FAILED)
        return 3;

    if(set_pcm() != 0)
    {
        printf("Error: PCM failure - ");
        return 1;
    }

    decode(fdm, stat.st_size);

    if (munmap(fdm, stat.st_size) == -1)
        return 4;

    snd_pcm_drain(handle);
    snd_pcm_close(handle);

    return 0;
}


int set_pcm()
{
    int rc;
    int dir = 0;
    int rate = 44100;
    int format = SND_PCM_FORMAT_S16_LE;
    int channels = 2;

    rc = snd_pcm_open(&handle, "default", SND_PCM_STREAM_PLAYBACK, 0);

    if(rc < 0)
    {
        perror("Error: open PCM device failed\n");
        exit(1);
    }

    snd_pcm_hw_params_alloca(&params);

    rc = snd_pcm_hw_params_any(handle, params);
    if(rc < 0)
    {
        perror(" (snd_pcm_hw_params_any)\n");
        exit(1);
    }

    rc = snd_pcm_hw_params_set_access(handle, params, SND_PCM_ACCESS_RW_INTERLEAVED);
    if(rc < 0)
    {
        perror(" (sed_pcm_hw_set_access)\n");
        exit(1);

    }

    rc = snd_pcm_hw_params_set_format(handle, params, SND_PCM_FORMAT_S16_LE);
    if(rc < 0)
    {
        perror(" (snd_pcm_hw_params_set_format failed)\n");
        exit(1);
    }

    rc = snd_pcm_hw_params_set_channels(handle, params, channels);
    if(rc < 0)
    {
        perror(" (snd_pcm_hw_params_set_channels)\n");
        exit(1);
    }

    rc = snd_pcm_hw_params_set_rate_near(handle, params, &rate, &dir);
    if(rc < 0)
    {
        perror(" (snd_pcm_hw_params_set_rate_near)\n");
        exit(1);
    }

    rc = snd_pcm_hw_params(handle, params);
    if(rc < 0)
    {
        perror(" (snd_pcm_hw_params)\n");
        exit(1);
    }

    return 0;
}

struct buffer {
    unsigned char const *start;
    unsigned long length;
};

static enum mad_flow input(void *data, struct mad_stream *stream)
{
    struct buffer *buffer = data;

    if (!buffer->length)
        return MAD_FLOW_STOP;

    mad_stream_buffer(stream, buffer->start, buffer->length);

    buffer->length = 0;

    return MAD_FLOW_CONTINUE;
}

static inline signed int scale(mad_fixed_t sample)
{
    sample += (1L << (MAD_F_FRACBITS - 16));

    if (sample >= MAD_F_ONE)
        sample = MAD_F_ONE - 1;
    else if (sample < -MAD_F_ONE)
        sample = -MAD_F_ONE;

    return sample >> (MAD_F_FRACBITS + 1 - 16);
}

static enum mad_flow output(void *data, struct mad_header const *header, struct mad_pcm *pcm)
{
    unsigned int nchannels, nsamples,n;
    mad_fixed_t const *left_ch, *right_ch;

    nchannels  = pcm->channels;
    n=nsamples = pcm->length;
    left_ch    = pcm->samples[0];
    right_ch   = pcm->samples[1];

    unsigned char Output[6912], *OutputPtr;
    int fmt, wrote, speed, exact_rate, err, dir;

    OutputPtr = Output;

    while (nsamples--)
    {
        signed int sample;

        sample = scale(*left_ch++);

        *(OutputPtr++) = sample >> 0;
        *(OutputPtr++) = sample >> 8;

        if (nchannels == 2)
        {
            sample = scale (*right_ch++);
            *(OutputPtr++) = sample >> 0;
            *(OutputPtr++) = sample >> 8;
        }
    }

    OutputPtr = Output;
    snd_pcm_writei (handle, OutputPtr, n);
    OutputPtr = Output;

    return MAD_FLOW_CONTINUE;
}

static enum mad_flow error(void *data, struct mad_stream *stream, struct mad_frame *frame)
{
    struct buffer *buffer = data;
    fprintf(stderr, "decoding error 0x%04x (%s) at byte offset %u\n",
            stream->error, mad_stream_errorstr(stream),
            stream->this_frame - buffer->start);

    return MAD_FLOW_CONTINUE;
}

static int decode(unsigned char const *start, unsigned long length)
{
    struct buffer buffer;
    struct mad_decoder decoder;
    int result;

    buffer.start  = start;
    buffer.length = length;

    mad_decoder_init(&decoder, &buffer, input, 0, 0, output, error, 0);

    result = mad_decoder_run(&decoder, MAD_DECODER_MODE_SYNC);

    mad_decoder_finish(&decoder);

    return result;
}
