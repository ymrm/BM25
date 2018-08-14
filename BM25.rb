#!/usr/lib/ruby
# -*- coding: utf-8 -*-
require 'bigdecimal'
require 'bigdecimal/util'

require 'natto'

text_file = "sinsyo_list.txt" #新書として扱うデータだけを出力したテキスト
#text_file = "sinsyo_list_mini.txt" #新書として扱うデータだけを出力したテキス ト
file = open(text_file)
text = Array.new
file.each_line {|line|
  line.chomp! #**********を目印に1冊ずつに区切る
  text.push(line)
}
text = text.join(",")
#p text
# text.each{
#}#
allay1 = Array.new
allay1 = text.split(",**********")
#p allay1[0]
allay2 = Array.new #二重配列にする
allay1.each {|a|
  b = a.split(",")
  allay2.push(b)
}
#p allay2

allay3 = Array.new #ハッシュを入れる配列
h = Hash.new #配列をハッシュ化
allay2.each{|a|
  h = Hash[*a]
  allay3.push(h)
}
#p allay3
natto = Natto::MeCab.new
words_hash = Hash.new { |h,k| h[k] = {} } #単語を数える {文学=>{国語=>4,漢字=>2}}
words_array = Hash.new  {|h,k| h[k] = []}#カウントせず、重複単語が存在する状 態の配列が欲しい
allay3.each{|a|

  titl = a["01"] #タイトル
  if titl != nil
     natto.parse(titl) do |n|
       if n.feature.match("名詞")
         words_array[a["01"]].push(n.surface)
        # if words_hash[a["01"]].key?(n.surface) #既にその単語があれば #1冊ず つ単語を集計
        #   words_hash[a["01"]][n.surface] += 1
        # else #なければ
        #   words_hash[a["01"]][n.surface] = 1
        # end
       end
    end
  end




  inst = a["08"]#内容説明
  if inst != nil
    natto.parse(inst) do |n|
      if n.feature.match("名詞")
         words_array[a["01"]].push(n.surface)
       # if words_hash[a["01"]].key?(n.surface) #既にその単語があれば #1冊ず つ単語を集計
       #   words_hash[a["01"]][n.surface] += 1
       # else #なければ
       #   words_hash[a["01"]][n.surface] = 1
       # end
      end
    end
  end

  cont = a["09"] #目次
  if cont != nil
     natto.parse(cont) do |n|
       if n.feature.match("名詞")
         words_array[a["01"]].push(n.surface)
        # if words_hash[a["01"]].key?(n.surface) #既にその単語があれば #1冊ずつ単語を集計
        #   words_hash[a["01"]][n.surface] += 1
        # else #なければ
        #   words_hash[a["01"]][n.surface] = 1
        # end
       end
    end
  end
}

#標準入力で新書本を入力
select_books = ARGV
p select_books #選択された新書本を表示

select_words = Array.new #選択された新書本の単語を収録する配列
select_books.each{|k1,v1|
  words_array.each{|k2,v2|
    if k1 == k2
      select_words.push(v2)
  #    p v2
    end
  }
}
#p select_words #二重配列
select_words = select_words.flatten.uniq

#p select_words #一次元配列



###########################################################################################################
#学問TFを実行結果のテキストからもってくる
text_file = "gakumon_tf.txt"
file = open(text_file)

text = Array.new
file.each_line {|line|
  line.chomp!
  text.push(line)
}
#p text

#学問TFの結果を解釈
text2 = Array.new
text.each {|a|
  text2.push(a.split(",")) #カンマで区切りの配列
}
#p text2 

tf_a = Array.new
text2.each{|a|
  select_words.each{|w|
    if a[1] == w
      tf_a.push(a)
    end
  }
}
##########################################################################################
#学問IDFを実行結果のテキストからもってくる
text_file = "gakumon_idf.txt"
file = open(text_file)

text = Array.new
file.each_line {|line|
  line.chomp!
  text.push(line)
}
#p text

#学問TFの結果を解釈
text2 = Array.new
text.each {|a|
  text2.push(a.split(",")) #カンマで区切りの配列
}
#p text2 
idf_a = Array.new
text2.each{|a|
  select_words.each{|w|
    if a[0] == w
      idf_a.push(a)
    end
  }
}
##########################################################################################
#学問DLを実行結果のテキストからもってくる
text_file = "gakumon_dl.txt"
file = open(text_file)

text = Array.new
file.each_line {|line|
  line.chomp!
  text.push(line)
}
dl_a = Array.new
  text.each {|a|
  dl_a.push(a.split(",")) #バーで区切ったものが二重配列の最も中身
}
#p dl_a #[単語,DL]
dl_sum = 0
dl_a.each{|a|
  dl_sum += a[1].to_i
}
#p dl_sum
#p dl_a.size
avgdl = dl_sum.to_f/dl_a.size
#p text
#p dl_a
#p tf_a
#p idf_a
bm25_a = Array.new #BM25の値を格納し、最後に学問ごとに集計
tf_a.each{|a|
  dl_a.each{|c|
  if a[0] == c[0]
    idf_a.each{|b|
      if a[1] == b[0]
        dl = c[1].to_f
        tf = a[2].to_f
        idf =  b[1].to_f
        tfidf = tf * idf
        k = 2.0
        b = 0.75
         score = (idf*((tf*(k+1)).to_d.to_f)/(tf+k*(1-b+(b*dl/avgdl))).to_d.to_f).to_d.to_f #to_d tio_iで浮動小数点の処理
#p ((tf*(k+1))).to_d.to_f
#p (tf+k*(1-b+(b*dl/avgdl))).to_d.to_f
        print a[0],",",a[1],",",score,"\n"
        bm25_a.push([a[0],score])
      end
    }
  end
  }
}
#p bm25_a
bm25_h = Hash.new
bm25_h = bm25_a.each_with_object(Hash.new(0)) {|(k,v), h| h[k] += v}
p bm25_h.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
