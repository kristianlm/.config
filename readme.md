# Kristian's .config directory

This is just my personal stuff. A collection of random things that I
find useful.

## Noise Reduction

I've fiddled around and managed to use `sox`. It's nice, and you don't
need to make files out of the noise profile and things like that:

    sox /tmp/recording.flac -n trim 00:01 =00:04 noiseprof \
      | sox /tmp/recording.flac -t flac - noisered - 0.1 \
      | ffmpeg -i - -ar 44800 -f flac -
      | mpv -

This does the following:

1. make a noise profile from second 1 to second 4 in the original clip
   (having manually found a silent part)
2. remove the noise from the original clip, encoding a new flac file
   which goes to stdout
3. down-sample that file (`sox` could probably do this better, but
   92kHz goes easy into 48kHz)
4. play it

You can adjust 0.1 for more or less agressive noise cancelling. Too
much probably makes voices sound robotic etc.

## [ Norwegian ] Printing stuff

Fra 8 sider US Letter til 2 dobbeltsider A3

Jeg hadde en PDF på 8 sider som jeg ville printe ut som en "booklet" i
A3. Etter mye styr kom jeg frem til at `pdfjam` var min eneste
hjelpsomme venn.

```bash
pdfjam ~/Downloads/SaleilFeeleySFPW15.pdf --a4paper --outfile /tmp/a4.pdf
pdfjam /tmp/a4.pdf '{},1,2,{},  {},3,4,9, 8,5,6,7' --outfile /tmp/a4up.pdf
pdfjam --nup 2x1 --landscape /tmp/a4up.pdf --a3paper --outfile /tmp/a3.pdf
lpr -P m750-ipp -o sides=two-sided-short-edge -o media=a3 -o landscape /tmp/a3.pdf
```
