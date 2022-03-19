#!/bin/bash

main(){
  domains=(sr sj rk jk u si)
  for i in {1..12} ${domains[@]}
  #for i in {1..4}
  do
    if [[ "$i" = [1-9] ]]; then
      i="0${i}"
    fi
    html_file="program${i}.html"
    labels=(${labels[@]} $i)
    download_html $html_file

    jps_file="_jps_${i}.txt"
    title_extraction $html_file $jps_file
    word_extraction $jps_file
    wordcloud_gen $jps_file
    hist_file="hist_jps_${i}.txt"
    wrod_histogram_gen $jps_file $hist_file

    png_file="_jps_${i}.png"
    imagemagick_commands  $png_file
  done
  merging_wordclouds ${labels[@]}
  removing_temp_files
}

download_html(){
  html_file=$1
  web_site_path="https://onsite.gakkai-web.net/jps/jps_search/2022sp/data2/html"
  if [[ ! -f "$html_file" ]]; then
    wget $web_site_path/$html_file
    echo "---> Downloaded $html_file."
  fi
}

title_extraction(){
  html_file=$1
  jps_file=$2
  python3 html_parse.py $html_file > $jps_file
  temp_file="_tmp.txt"
  grep -A1 title $jps_file | grep -v title | grep -v "\-\-" > $temp_file; mv $temp_file $jps_file
  stopwords=(（一般シンポジウム講演） （共催シンポジウム講演） （チュートリアル講演） \
    （若手奨励賞） 取　　消 （企画講演） 一般社団法人日本物理学会 趣旨説明 まとめ 移　　動)
  for word in ${stopwords[@]}
  do
    cat $jps_file | sed "s/${word}//g" > $temp_file; mv $temp_file $jps_file
  done
  cat $jps_file | sed "s/Back to Top//g" > $temp_file; mv $temp_file $jps_file
  echo "---> Extracted titles ($jps_file)"
}

word_extraction(){
  jps_file=$1
  temp_file="_tmp.txt"
  cat $jps_file | sudachipy -a -m C > $temp_file; mv $temp_file $jps_file
  stopwords=(助詞 EOS 補助記号 助動詞 数詞 空白 おけ よる 的 用い)
  for word in ${stopwords[@]}
  do
    grep -v $word $jps_file > $temp_file
    mv $temp_file $jps_file
  done
  cat $jps_file | awk '{print $1}' > $temp_file; mv $temp_file $jps_file
  echo "---> Extracted words ($jps_file)"
}

wordcloud_gen(){
  jps_file=$1
  python3 wordcloud_gen.py $jps_file
}

wrod_histogram_gen(){
  jps_file=$1
  hist_file=$2
  temp_file="_tmp.txt"
  sort $jps_file | uniq -c | sort -gr > $temp_file
  mv $temp_file $hist_file
  echo "---> Generated histogram ($hist_file)"
}

imagemagick_commands(){
  png_file=$1
  width=$(identify -format "%[width]" ${png_file})
  alpha=$((width/20))
  rectangle1=$((width/12))
  rectangle2=$((10+alpha))
  beta=$((width/500))
  pointsize=$((25*beta))
  text_y=$((20*beta+10))
	convert $png_file \
    -fill '#0008' -draw "rectangle 0,0,${rectangle1},${rectangle2}" \
    -fill white -pointsize ${pointsize} -font Helvetica \
    -draw "text 20,${text_y} '$i'" -background white _${png_file}
  mv _${png_file} $png_file
  echo "---> Generated wordcloud ($png_file)"
}

merging_wordclouds(){
  labels=($@)
  for i in {0..8}
  do
    png_file1="_jps_${labels[$((2*i))]}.png"
    png_file2="_jps_${labels[$((2*i+1))]}.png"
    merge_file="_merge_jps_${labels[$((2*i))]}_${labels[$((2*i+1))]}.png"
    convert +append $png_file1 $png_file2 $merge_file 
  done
  for i in {0..3}
  do
    png_file1="_merge_jps_${labels[$((4*i))]}_${labels[$((4*i+1))]}.png"
    png_file2="_merge_jps_${labels[$((4*i+2))]}_${labels[$((4*i+3))]}.png"
    merge_file="merge_jps_${labels[$((4*i))]}-${labels[$((4*i+3))]}.png"
    convert -append $png_file1 $png_file2 $merge_file
  done
  png_file="_merge_jps_${labels[16]}_${labels[17]}.png"
  mv -v $png_file ${png_file#_}
}

removing_temp_files(){
  rm -v _jps_*.txt
  rm -v _jps_*.png
  rm -v _merge_jps_*.png
  echo "---> Removed temporary files."
}

main $@
