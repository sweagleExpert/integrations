# objectify/1 takes an array of string values as inputs, converts
# numeric values to numbers, and packages the results into an object
# with keys specified by the "headers" array
def objectify(headers):
  # For jq 1.4, replace the following line by: def tonumberq: .;
  def tonumberq: tonumber? // .;
  . as $in
  | reduce range(0; headers|length) as $i ({}; .[headers[$i]] = ($in[$i] | tonumberq) );

def tsv2table:
  # For jq 1.4, replace the following line by:  def trim: .;
  def trim: sub("^ +";"") |  sub(" +$";"") |  sub("\"";"") |  sub("\"+$";"");
  split("\r\n") | map( split("\t") | map(trim) );

def tsv2json:
  tsv2table
  | .[0] as $headers
  | reduce (.[1:][] | select(length > 0) ) as $row
      ( []; . + [ $row|objectify($headers) ]);

tsv2json
