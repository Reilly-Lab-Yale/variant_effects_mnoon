#stock python, not in a particular env.
#best run in pypy3 for speed. 

#takes a single-nucleotide bedgraph (assuming sorted by coord) & computes the max at each pos. (That's max by abs).
import sys

def main():
	previous_pos=False
	max_seen=None
	
	for line in sys.stdin.buffer:
		line=line.decode()
		line=line.rstrip('\n').split('\t')
		if line[0:3]!=previous_pos:
			if previous_pos != False:
				#new position: just print the old line & save the new line
				print(f"{previous_pos[0]}\t{previous_pos[1]}\t{previous_pos[2]}\t{max_seen}")
			else:
				pass
				#if first line: skip printing
			previous_pos=line[0:3]
			max_seen=float(line[3])
		else:
			#dealing with a duplicate line, record max of duplicate lines seen so far & move on
			if abs(float(line[3]))>abs(float(max_seen)):
				max_seen=line[3]
			pass
			
	#flush final line
	print(f"{previous_pos[0]}\t{previous_pos[1]}\t{previous_pos[2]}\t{max_seen}")

if __name__=="__main__":
	main()