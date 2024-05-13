The formatting of the .out file is very strange. Take a look at the header:
```
   SW  perc perc perc  query      position in query           matching       repeat              position in  repeat
score  div. del. ins.  sequence    begin     end    (left)    repeat         class/family         begin  end (left)   ID

```

...It's two lines of text and one blank line. How odd for the header to not be machine-readble! Oh well, we'll soon fix that.
I manually modified the above header to the single-line header below:

```
SW_score perc_div perc_del perc_ins query_sequence pos_in_query_begin pos_in_query_end (left) matching_repeat repeat_class_slash_family position_in_repeat_begin position_in_repeat_end position_in_repeat_left id
```

Note also that the delimiters are inconsistent, & seem to be optimized for human readability rather than machine readability (made up of an inconsistent number of whitespace characters). I will not modify this now, but will instead simply make sure to account for this formatting when reading the data into pyspark. 