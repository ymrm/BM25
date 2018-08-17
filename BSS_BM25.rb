#!/usr/lib/ruby
# -*- coding: utf-8 -*-
require 'bigdecimal'
require 'bigdecimal/util'

require 'natto'

#新書本ごとに単語を入手(クエリ)
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

#########################################################################
#対象とする新書本を選択し、その新書本に付随するクエリを入手
#標準入力で新書本を入力
select_books = ARGV
p select_books #選択された新書本を表示

#クエリの単語の配列
select_words = Array.new #選択された新書本の単語を収録する配列
select_books.each{|book|
  words_array.each{|k,v|
    if book == k
      select_words.push(v)
  #    p v2
    end
  }
}
#p select_words #二重配列
select_words = select_words.flatten
#p select_words #一次元配列

#クエリの単語のハッシュ
p select_words.size 
select_words_hash = Hash.new
select_words.each{|a| 
  if select_words_hash.key?(a) #既に単語があれば
    select_words_hash[a] += 1
  else #なければ
    select_words_hash[a] = 1
  end
}
#p select_words_hash
########################################################################
#文書側(学問側)の情報を入手
text_file = "toc_body_scrape.txt"
#text_file = "toc_body_scrape_mini.txt"
file = open(text_file)

text = Array.new
file.each_line {|line|
  line.chomp!
  text.push(line)
}
#p text

#1要素ずつ配列に入れる
text2 = Array.new
  text.each {|a|
  text2.push(a.split("|")) #バーで区切ったものが二重配列の最も中身
}

 #全角カッコを半角カッコに変換する
 text2.each{|a|
  a[3].gsub!(/（/,"(")
  a[3].gsub!(/）/,")")
 }

 #学問とマッチさせるために、text2を修正していく
 ##学科にあたる区分がない場合
 text2.each {|a|
 if a[3] =~ /なし/ #なしと書いてあるので、
   a[3] = a[2]  #繰り下げ?
 #print a[1],"|",a[2],"|",a[3],"\n"
 end
 }

 #学科の場合は末尾を消す
 text2.each {|a|
   if a[3] =~ /学科$/
      a[3].chop! #学科のほうだけ末尾の文字を消す
   end
 }


##########################################################################################
text_file = "04.csv"
file = open(text_file)

text_ = Array.new
file.each_line {|line|
  line.chomp!
  text_.push(line)
}
#p text_
kubun_syoukubun = Hash.new # 採用区分とその中身のハッシュ
text2_ = Array.new #カンマで区切る

text_.each{|a|
  text2_.push(a.split(",")) #カンマで区切ったものが二重配列の最も中身
}
#print "*"
#p
#print "*"

hash = Hash.new #04.csvのあるべき姿

text2_.each{|a|
  hash[a[0]] = a #0番目をキーとして、0番目も含めて、ハッシュにしてしまう
}
#p hash

hash.each{|k,v|
  v.shift #0番目の要素だけを消す
}
#p hash


#
natto = Natto::MeCab.new
#学問区分ごとに区分する場合
words_hash = Hash.new { |h,k| h[k] = {} } #単語を数える {文学=>{国語=>4,漢字=>2}}

hash.each{|k,v|
  v.each{|a|
    text2.each{|b| #学科紹介文のほうと照合する
      #p b[3]
      if a == b[3]
        if b[5] != nil
          natto.parse(b[5]) do |n|
            if n.feature.match("名詞")
              if words_hash[k].key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                words_hash[k][n.surface] += 1
              else #なければ
                words_hash[k][n.surface] = 1
                #puts "#{n.surface}: #{n.feature}"
              end
            end
          end
        end
        if b[4] != nil
          natto.parse(b[4]) do |n|
            if n.feature.match("名詞")
              if words_hash[k].key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                words_hash[k][n.surface] += 1
              else #なければ
                words_hash[k][n.surface] = 1
                #puts "#{n.surface}: #{n.feature}"
              end
            end
          end
        end
      end
    }
  }
}
words_hash.each{|k,v|
#  print k,"\n"
  v.each{|vk,vv|
#    print vk,",",vv,"\n"
  }
}

#学m本区分ごとの総単語数(延べ)を求める
real_add = 0
words_hash.each{|k,v|
#  print k,"|" #学問区分
  v.each{|kk,vv|
#  if kk == "," #カンマだけこの後でエラーを起こしているので、ここでなかったことにする
#    add = v.values.inject(:+)
#    real_add = add - vv #カンマの分の単語数を引く
#    break #ここでbreakしないと引く前の合計値が上書きされてしまう
#  else
    real_add = v.values.inject(:+) #学問分野ごとの総単語数(延べ)
#  end
  }
#  p real_add #学問分野ごとの総単語数(延べ)
}

#########################################################
#学問区分ごとに区分しない場合
words_hash_all = Hash.new

hash.each{|k,v|
  v.each{|a|
    text2.each{|b| #学科紹介文のほうと照合する
      #p b[3]
      if a == b[3]
        if b[5] != nil
          natto.parse(b[5]) do |n|
            if n.feature.match("名詞")
              if words_hash_all.key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                words_hash_all[n.surface] += 1
              else #なければ
                words_hash_all[n.surface] = 1
                #puts "#{n.surface}: #{n.feature}"
              end
            end
          end
        end
        if b[4] != nil
          natto.parse(b[4]) do |n|
            if n.feature.match("名詞")
              if words_hash_all.key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                words_hash_all[n.surface] += 1
              else #なければ
                words_hash_all[n.surface] = 1
                #puts "#{n.surface}: #{n.feature}"
              end
            end
          end
        end
      end
    }
  }
}

dl_hash = Hash.new #文書ごとにdlを計算する
avdl = 0 #文書長を足していく
words_hash.each{|k,v|
#  p k #学問
  v.values.inject(:+) #DL
  dl_hash[k] = v.values.inject(:+) #DL
  avdl += v.values.inject(:+) #全文書の単語を足していく
}
#p words_hash.size #文書数(54)
avdl = avdl.to_f/words_hash.size #平均で上書き
#p dl_hash

k_hash = Hash.new
dl_hash.each{|k,v|
  k1 = 1.2.to_d
  b = 0.75.to_d
  k_hash[k]=(k1*((1-b)+b*(v.to_d/avdl.to_d))).to_f
}
p k_hash
########################################################################
#BM25の計算をする

#タームごとにw(1)を求める
#あたえられたクエリの1タームずつで繰り返す

#タームを含む文書数を算出
n_hash = Hash.new {|h,k| h[k] = {} }
select_words.each{|word| #クエリ
  words_hash.each{|gakumon,v| #文書
  v.each{|v_word,v_kazu|
    if word == v_word #クエリと一致する文書内の単語があれば、
      if n_hash[word].key?(gakumon) #タームごとに出現する文書数をカウント
        n_hash[word][gakumon] += 1
      else
        n_hash[word][gakumon] = 1
      end
    end
    }
  }
}


idf_hash = Hash.new #タームごとのIDF(w)
include Math
select_words.each{|word|
  n_hash.each{|n_hash_term,n_hash_n|
  if word == n_hash_term
    n = n_hash_n.size.to_d #既に計算済み
    nn = words_hash.size.to_d #学問数54
    w_mother = nn-n+0.5.to_d #分母
    w_child = n+0.5.to_d #分子
    idf = (log2(w_child/w_mother)).to_f #BM25用のIDF
    idf_hash[word] = idf
  end
  }
}
p idf_hash

#tf
#p words_hash
tf_array = Array.new
select_words.each{|word|
  words_hash.each{|k,v|
#    p v.values.inject(:+) #TFの分母
    v.each{|vk,vv|
      if word == vk
#        p vv #TFの分子
#        p k
#        p word
        tf = vv.to_f/v.values.inject(:+)
#        p tf
        tf_array.push([k,word,tf])
      end
    }
  }
}
p tf_array
#qtf
qtf_hash = Hash.new
select_words.each{|word|
  select_words_hash.each{|h_word,h_kazu|
  if word == h_word
    #p word
    h_kazu #qtfの分子
    select_words.size #qtfの分母
    qtf = h_kazu.to_f/select_words.size
    qtf_hash[word] = qtf
  end
  }
}
p qtf_hash

k1 = 1.2.to_d
b = 0.75.to_d
k3 = 1000.to_d

#学問ごとにBM25を計算
bm25_hash = Hash.new {|h,k| h[k]=[]}
k_hash.each{|gakumon1,k|
  tf_array.each{|a|
  if a[0] == gakumon1
    qtf_hash.each{|term1,qtf|
      idf_hash.each{|term2,idf|
      if a[1] == term1 && term1 == term2
        p gakumon1
        p term1
        p tf = a[2].to_d
        p k = k.to_d
        p idf = idf.to_d
        p qtf = qtf.to_d
        bm25 = idf * (((k1+1)*tf)/(k+tf)) * ((k3+1)*qtf)/(k3+qtf)
        bm25_hash[gakumon1].push(bm25)
      end
      }
    }
  end
  }
}
bm25_hash2 = Hash.new
bm25_hash.each{|k,v|
  bm25_hash2[k] = (v.inject(:+)).to_f
}
p bm25_hash2.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
