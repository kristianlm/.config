# Fra 8 sider US Letter til 2 dobbeltsider A3

Jeg hadde en PDF på 8 sider som jeg ville printe ut som en "booklet" i A3. Etter mye styr kom jeg frem til at `pdfjam` var min eneste hjelpsomme venn.

```bash
pdfjam ~/Downloads/SaleilFeeleySFPW15.pdf --a4paper --outfile /tmp/a4.pdf
pdfjam /tmp/a4.pdf '{},1,2,{},  {},3,4,9, 8,5,6,7' --outfile /tmp/a4up.pdf
pdfjam --nup 2x1 --landscape /tmp/a4up.pdf --a3paper --outfile /tmp/a3.pdf
lpr -P m750-ipp -o sides=two-sided-short-edge -o media=a3 -o landscape /tmp/a3.pdf
```

