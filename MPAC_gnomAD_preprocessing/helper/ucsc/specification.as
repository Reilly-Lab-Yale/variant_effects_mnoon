table hg38
"description"
(
string  chrom;		"0 Reference sequence chromosome or scaffold"
uint    chromStart;	"1 Start position of feature on chromosome"
uint    chromEnd;	"2 End position of feature on chromosome"
string  rsid;   "3 rsID if one exists, or '.' otherwise"
string  ref_allele; "4 Reference allele"
string alt_allele; "5 Alternate allele"
float   ref_mpac;    "6 Reference allele MPAC score"
float   alt_mpac;    "7 Alternate allele MPAC score"
float    skew;   "8 Predicted alleleic skew between reference and alternate."
string  color;  "9 Red if variant is an emvar, blue otherwise."
char    emvar;  "10 Predicted emvar status"
)