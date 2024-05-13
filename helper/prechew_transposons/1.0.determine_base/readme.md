# Background

It's not clear, looking at the transposon file downloaded in the previous step, if the numbers are 0-based or 1-based. To resolve this, I will take a look at one of the actual masked files, & make a prediction as to what the coordinates should be for a handful of transposons, if the files are 0 or 1 based. Then I 

Again examining https://hgdownload.cse.ucsc.edu/goldenpath/hg38/bigZips/ , we see

> hg38.fa.gz - "Soft-masked" assembly sequence in one file.
>     Repeats from RepeatMasker and Tandem Repeats Finder (with period of 12 or
>     less) are shown in lower case; non-repeating sequence is shown in upper
>     case. (again, the most current version of this file is latest/hg38.fa.gz)

I downloaded a copy onto my local machine, and examined it.

Restricting our scope to the first chromosome,
Each line is 50 characters long, except the first line which is just a fasta header '>chr1'
So to get the character number at, say, the end of line 100, we would compute (100-1)*50.

Chr1        T   A   C   G   T
          | | | | | | | | | |
1 based   | 1 | 2 | 3 | 4 | 5
0 based   0   1   2   3   4

# First annotation

## Predict

(line 202) thru (all but the last 3 nucleotides of line 230) are lowercase.

If this was one-based
- start is (201-1) * 50 + 1 = 10001
  - (first lowercase letter in anno is first character of line 202, which is "first 201 lines plus 1")
- end is (230-1) * 50 - 3  = 11447
  - (last lowercase letter is 3 characters from the end of the line)

If this was zero-based,
- start would be one lower to properly capture the first nucleotide. So start=10001-1=10000
- end would be the same number, 11447

## Check

   SW  perc perc perc  query      position in query           matching       repeat              position in  repeat
score  div. del. ins.  sequence    begin     end    (left)    repeat         class/family         begin  end (left)   ID

  463   1.3  0.6  1.7  chr1        10001   10468 (248945954) +  (TAACCC)n      Simple_repeat            1  471    (0)      1
 3612  11.4 21.5  1.3  chr1        10469   11447 (248944975) C  TAR1           Satellite/telo       (399) 1712    483      2

The first two rows correspond to this string of lower-case letters : there are actually two repetitive sequences adjacent to each other. 

# Second annotation

## Prediction

(excluding first four characters of line 232) through (the first 25 letters of line 235)

If one-based

start= (231-1)*50                         +4                        +1 
        ^ beginning of lower-case        ^ excluding first four    ^ moving onto lowercase       
        is end of line 231 (sub 1)        upper-case letters
        for fasta annotation

    = 11505

end = (234-1)*50              + 25
      ^ all characters in     ^ past first 25 letters 
        first 234 lines

    = 11675 , the last lowercase letter in this annotation.

## Checking

   SW  perc perc perc  query      position in query           matching       repeat              position in  repeat
score  div. del. ins.  sequence    begin     end    (left)    repeat         class/family         begin  end (left)   ID
484  25.1 13.2  0.0  chr1        11505   11675 (248944747) C  L1MC5a         LINE/L1             (2382)  395    199      3

Consistent w/ 1-based. 

# Conclusion

It seems that the .out file is 1-based! This is a tad unusual, as BED files are usually 0-based, and this output is BED-like, but whatever. 