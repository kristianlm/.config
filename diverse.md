# Fra 8 sider US Letter til 2 dobbeltsider A3

Jeg hadde en PDF på 8 sider som jeg ville printe ut som en "booklet" i A3. Etter mye styr kom jeg frem til at `pdfjam` var min eneste hjelpsomme venn.

```bash
$ pdfjam ~/Downloads/s3_letter.pdf --a4paper --outfile /tmp/s3_a4.pdf
$ pdfjam /tmp/s3_a4.pdf '8,1,2,7, 6,3,4,5' --outfile /tmp/s3_a4_reorder.pdf
$ pdfjam --batch --nup 2x1 --suffix 2up --landscape /tmp/s3_a4_reorder.pdf --a3paper --outfile /tmp/s3_a3_reorder-2up.pdf
```

Siste `pdf`en kan du printe med "two-sided-short-edge". Yey!
