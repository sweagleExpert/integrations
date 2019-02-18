jq --slurp --raw-input \
   'split("\n") | .[1:] | map(split(";")) |
      map({
         "position": [.[0], .[1]],
         "taxo": {
             "espece": .[2]
          }
      })' \
  input.csv > output.json
