#!/usr/lib/ruby
# -*- coding: utf-8 -*-
require 'bigdecimal'
require 'bigdecimal/util'
require 'natto'
###########################################################################################################
#紹介文部分をもってくる
#text_file = "toc_body_scrape_sample.txt"
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


words_array_all = words_hash_all.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
words_array_all.each{|a|
#  print a[0],",",a[1],"\n"
}
########################################################
#IDF下準備 #以下新書本側のIDF算出と同様
#IDF下準備
idf_hash = Hash.new{ |h, k| h[k] = [] } #値が配列のハッシュ
#配列を2種類作成する
idf_array = Array.new #新書本と単語のペア
all_words = Array.new #全単語を格納する配列
words_hash.each{|sinsyo,v|
  v.each{|word,kazu|
    idf_array.push([sinsyo,word])
    idf_hash[sinsyo].push(word)
    all_words.push(word)
  }
}
#p idf_hash.size
#p idf_array

#単語がキー、新書本が値になるハッシュを作成する
word_key_hash = Hash.new{|h,k| h[k] = []}#単語がキー、新書本が値
all_words.each{|all_word|
  idf_array.each{|a|
      if a[1] == all_word
        word_key_hash[all_word].push(a[0]) #単語がキーとなっているところに、 新書本を値として追加していく
      end
  }
}
word_key_hash.each{|v,k|
  k.uniq! #新書本をユニークにする
}
#p word_key_hash
#IDF
idf_uniq = Hash.new #重複があるので、単語がキー、IDFが値のハッシュを作成する
include Math
all_words.each{|all_word|
  word_key_hash.each{|v,k|
  if all_word == v
#p k.size
#p idf_hash.size
    #print all_word,","
    all_n = idf_hash.size.to_f #全文書数
    n =  k.size.to_f #この単語が出現する文書の数
    idf = log2(all_n/n) #普通のIDF
    idf_bm25 = (log2((all_n.to_d-n.to_d+0.5.to_d)/(n.to_d+0.5.to_d))).to_f #BM25用のIDF
    idf_uniq[all_word] = idf_bm25 #BM25用のIDFに変更
   # print idf,"\n"
  end
  }
}

#表示
idf_uniq.each{|k,v|
print k,","
print v,"\n"
}
