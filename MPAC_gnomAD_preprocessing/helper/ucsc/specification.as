table hg38
"description"
(
string  chrom;		"Reference sequence chromosome or scaffold"
uint    chromStart;	"Start position of feature on chromosome"
uint    chromEnd;	"End position of feature on chromosome"
string  rsid;   "rsID if one exists, or '.' otherwise"
string  ref_allele; "Reference allele"
string alt_allele; "Alternate allele"
float   ref_mpac;    "Reference allele MPAC score"
float   alt_mpac;    "Alternate allele MPAC score"
float    skew;   "Predicted alleleic skew between reference and alternate."
char    emvar;  "Predicted emvar status"
)