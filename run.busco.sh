# conda activate bacgen3

#source /Users/wangdi/apps/anaconda3/bin/activate bacgen3
source /data/wangdi/bin/anaconda3/bin/activate bacgen3

LIST=$1

echo "## Complete BUSCOs (C)" > ${LIST}.busco.sum.txt
echo "## Complete and single-copy BUSCOs (S)" >> ${LIST}.busco.sum.txt
echo "## Complete and duplicated BUSCOs (D)" >> ${LIST}.busco.sum.txt
echo "## Fragmented BUSCOs (F)" >> ${LIST}.busco.sum.txt
echo "## Missing BUSCOs (M)" >> ${LIST}.busco.sum.txt
echo "## Total BUSCO groups searched" >> ${LIST}.busco.sum.txt
echo "## strain,C,S,D,F,M,n" >> ${LIST}.busco.sum.txt

## loop list
for f in `cat $LIST`
do

## copy fasta
cat ./fna/${f}.fasta > ${f}.fna

echo "== $f =="

##
## download busco db
##
## https://busco-data.ezlab.org/v5/data/lineages/campylobacterales_odb10.2020-03-06.tar.gz
busco -m genome -i ${f}.fna -o ${f} -l ./busco_dbs/lineages/campylobacterales_odb10

## length
len=$(seqlen.sh ${f}.fna | awk '{print $2}')

## combine all
line=$(grep "C:" ${f}/short_summary.specific.campylobacterales_odb10.${f}.txt | sed 's/\[/,/; s/\]//' | sed 's/C://; s/S://; s/D://; s/F://; s/M://; s/n://'| awk '{print $1}')
echo "$f,$len,$line" >> ${LIST}.busco.sum.txt

rm -rf ${f}.fna

done

