#!/usr/bin/ruby
# -*- config utf-8 -*-
require 'natto' #文書を単語に分ける


text_file = "sinsyo_list.txt" #新書として扱うデータだけを出力したテキスト
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
allay3.each{|a|

  titl = a["01"] #タイトル
  if titl != nil
     natto.parse(titl) do |n|
       if n.feature.match("名詞")
         if words_hash[a["01"]].key?(n.surface) #既にその単語があれば #1冊ず つ単語を集計
           words_hash[a["01"]][n.surface] += 1
         else #なければ
           words_hash[a["01"]][n.surface] = 1
         end
       end
    end
  end




  inst = a["08"]#内容説明
  if inst != nil
    natto.parse(inst) do |n|
      if n.feature.match("名詞")
        if words_hash[a["01"]].key?(n.surface) #既にその単語があれば #1冊ずつ単語を集計
          words_hash[a["01"]][n.surface] += 1
        else #なければ
          words_hash[a["01"]][n.surface] = 1
        end
      end
    end
  end

  cont = a["09"] #目次
  if cont != nil
     natto.parse(cont) do |n| 
       if n.feature.match("名詞")
         if words_hash[a["01"]].key?(n.surface) #既にその単語があれば #1冊ずつ単語を集計
           words_hash[a["01"]][n.surface] += 1
         else #なければ
           words_hash[a["01"]][n.surface] = 1
         end
       end
    end
  end
}

words_hash_all = Hash.new
allay3.each{|a|

  titl = a["01"] #タイトル
  if titl != nil
    natto.parse(titl) do|n|
      if n.feature.match("名詞")
        if words_hash_all.key?(n.surface) #既にその単語があれば #1冊ずつ単語 を集計
          words_hash_all[n.surface] += 1
        else #なければ
          words_hash_all[n.surface] = 1
        end
      end
    end
  end

  inst = a["08"] #内容説明
  if inst != nil
    natto.parse(inst) do |n|
      if n.feature.match("名詞")
        if words_hash_all.key?(n.surface) #既にその単語があれば #1冊ずつ単語を集計
          words_hash_all[n.surface] += 1
        else #なければ
          words_hash_all[n.surface] = 1
        end
      end
    end
  end

  cont = a["09"] #目次
  if cont != nil
     natto.parse(cont) do |n| 
       if n.feature.match("名詞")
         if words_hash_all.key?(n.surface) #既にその単語があれば #1冊ずつ単語を集計
           words_hash_all[n.surface] += 1
         else #なければ
           words_hash_all[n.surface] = 1
         end
       end
    end
  end
}

#標準入力
sinsyo = gets.chomp!
p sinsyo
words_hash.each{|k,v|
  if sinsyo == k
    print k,"\n"
    array = v.keys
    p array
  end
}
#=begin #全体での単語集計
words_array_all = words_hash_all.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
words_array_all.each{|a|
#  print a[0],",",a[1],"\n"
}
#=end


