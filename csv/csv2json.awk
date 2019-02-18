BEGIN{
  FS=","
  OFS=""
  getline #BEGIN runs before anything else, so grab the first line with the titles right away
  for(i=1;i<=NF;i++)
  names[i] = ($i)
  print "data = {"
}
{
  printf "  %s:{",($1)
  for(i=2;i<=NF;i++)
  {
    printf "'%s':%d%s",names[i],($i),(i == NF ? "" : ",")
  }
  print "},"
}
END{
  print "  null:{}\n}"  # the last item will have a comma after it;
                        # you need an element without a comma after
                        # you could also repeat the print block from the main loop
                        # without the very last comma;
                        # then it'd run on only the last line
}
