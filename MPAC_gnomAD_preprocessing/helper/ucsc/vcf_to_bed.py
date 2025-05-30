#stock python, not in a particular env.
#best run in pypy3 for speed. 

import sys

def main():
	for line in sys.stdin.buffer:
		line=line.decode()
		if line.startswith('#'):
			continue#skip commented lines
		#split on tabs
		line=line.rstrip('\n').split('\t')

		#split out info fields
		info=line[-1].split(';')
		#remove labels. 'ref, alt, skew' is the order
		info=[i.split('=')[1] for i in info]
		
		
		#remove old info representation
		line=line[:-1]
		#add processed info back to the line
		line=line+info
		
		#fields of inbound line are, in order; 0: CHROM, 1: POS, 2: ID, 3: REF, 4: ALT, 5: QUAL, 6: FILTER, 7: ref, 8: alt, 9: skew
		
		
		emvar=int(abs(float(line[9]))>0.5 and max(float(line[7]),float(line[8]))>1)

		#VCF files (the input) are 1-based, BED files (the output) are 0-based.
		print('\t'.join([line[0],str(int(line[1])-1),line[1]]+line[2:5]+line[7:]+[str(emvar)]))


if __name__=="__main__":
	main()