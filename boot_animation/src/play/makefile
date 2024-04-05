LDFLAGS= -lasound -lmad

all: mp3play

mp3play: mp3play.o
	$(CC) -static -o $@ $^ -lasound -lmad
	$(STRIP) mp3play

clean:
	rm -f mp3play.o mp3play play
