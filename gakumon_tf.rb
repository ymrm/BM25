#!/usr/lib/ruby
# -*- coding: utf-8 -*-
require 'bigdecimal'
require 'bigdecimal/util'

require 'natto'

text_file = "sinsyo_list.txt" #新書として扱うデータだけを出力したテキスト
text_file = "sinsyo_list_mini.txt" #新書として扱うデータだけを出力したテキス ト
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
select_words = select_words.flatten
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

text2.each{|a|
  select_words.each{|w|
    if a[1] == w
      p a
    end
  }
}
=begin
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

hash = Hash.new #04.csvのあるべき姿

text2_.each{|a|
  hash[a[0]] = a #0番目をキーとして、0番目も含めて、ハッシュにしてしまう
}
#p hash

hash.each{|k,v|
  v.shift #0番目の要素だけを消す
}


natto = Natto::MeCab.new
#学問区分ごとに区分する場合
words_hash = Hash.new { |h,k| h[k] = {} } #単語を数える {文学=>{国語=>4,漢字=>2}}
words_hash_2 = Hash.new { |h,k| h[k] = {} } #単語を数える {文学=>{国語=>4,漢字=>2}}
#p select_words
select_words.each{|w|
p w
  hash.each{|k,v|
    v.each{|a|
      text2.each{|b| #学科紹介文のほうと照合する
      #p b[3]
        if a == b[3]
          if b[5] != nil
            natto.parse(b[5]) do |n|
              if n.feature.match("名詞")
                if n.surface == w
                  if words_hash[k].key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                    words_hash[k][n.surface] += 1
                  else #なければ
                    words_hash[k][n.surface] = 1
                  end
                  if words_hash_2[k].key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                    words_hash_2[k][n.surface] += 1
                  else #なければ
                    words_hash_2[k][n.surface] = 1
                  end
                end
              end
            end
          end
          if b[4] != nil
            natto.parse(b[4]) do |n|
              if n.feature.match("名詞")
                if n.surface == w
                  if words_hash[k].key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                    words_hash[k][n.surface] += 1
                  else #なければ
                    words_hash[k][n.surface] = 1
                #puts "#{n.surface}: #{n.feature}"
                  end
                end
                  if words_hash_2[k].key?(n.surface) #既にその単語があれば #k(区分)ごとに集計
                    words_hash_2[k][n.surface] += 1
                  else #なければ
                    words_hash_2[k][n.surface] = 1
                  end
              end
            end
          end
        end
      }
    }
  }
}

#学問区分ごとの総単語数(延べ)を求める
real_add = 0
words_hash.each{|k,v|
#  print k,"|" #学問区分
  v.each{|kk,vv|
    real_add = v.values.inject(:+) #学問分野ごとの総単語数(延べ)
  }
#  p real_add #学問分野ごとの総単語数(延べ)
}


########################################################
#TF
#学問ごとの単語数
words_hash.each{|gakumon,v|
  words_hash_2.each{|gakumon2,v2|
    v.each{|word,kazu|
        print gakumon2,",",word,","
        sum = v2.values.inject(:+)
        p kazu
        p sum #分母は変わらず
        p tf_1 = (kazu.to_d / sum.to_d).to_f
    }
  }
}
=end
