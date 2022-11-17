from flask import Flask,render_template,request,jsonify
import pandas as pd
import pyspark
from pyspark.sql import *
from pyspark.sql.types import *
from pyspark import SparkContext, SparkConf
from pyspark.ml.fpm import FPGrowth
from pyspark.sql import functions as F
from flask import Flask,render_template,request
from rank_bm25 import BM25Okapi
import tqdm
import spacy
from rank_bm25 import BM25Okapi
from tqdm import tqdm
nlp = spacy.load("en_core_web_sm")
import annoy
import numpy as np
import time
from ftfy import fix_text 

application = Flask(__name__)

df = pd.read_csv('City_data1.csv')
user_inputs = []


@application.route("/") # root route
def home():
    del user_inputs[:]
    return render_template('index.html')

@application.route('/bestMatch', methods = ['GET','POST']) #best matched cities with word vectors similarity route
def best_match():
    search_string = request.args.get('q')
    ## start ##
    
    df['out'] = df['sights']+df['desc']+df['Best_time'] # update version 5 using descriptiona and sights 

    text_list = df.desc.str.lower().values
    tok_text=[] # for our tokenised corpus
   
    for doc in tqdm(nlp.pipe(text_list, disable=["tagger", "parser","ner"])): # controller pipeline
        tok = [t.text for t in doc if t.is_alpha]
        tok_text.append(tok)
    bm25 = BM25Okapi(tok_text) #vector search
    tokenized_query = str(search_string).lower().split(" ")
  
    t0 = time.time()
    results = bm25.get_top_n(tokenized_query, df.desc.values, n=6) #search result fixed at 6 for now
    t1 = time.time()
    print(f'{round(t1-t0,3) } seconds \n')

    cities = []
    countries = []
    imgs = []
    sights = []
    bts = []
    for i in results:
        city = df[df['desc']==str(i)]['city'].iloc[0]
        cities.append(city)
        cont = df[df['desc']==str(i)]['country'].iloc[0]
        countries.append(cont)
        img = df[df['desc']==str(i)]['img'].iloc[0]
        imgs.append(str(img))
        sight = str(df[df['desc']==str(i)]['sights'].iloc[0]).split(',')
        sights.append(sight)
        bt = df[df['desc']==str(i)]['Best_time'].iloc[0]
        bts.append(bt)
    ## end ##
    
    return render_template('best_match.html',results = results,cities = cities,countries = countries, imgs=imgs,sights = sights,bts = bts)
  

@application.route('/sim_city', methods = ['GET','POST']) #similar city matcher route
def similar_cities():
    
    input1 =  request.args.get('place1')
    input1 = input1.split(',')
    input1 = [i.strip().capitalize() for i in input1]
    print(input1)
    user_inputs.extend(input1)

    df1 = df[['city','beach','mountain','history','food','city_life','countryside','nightlife','couple_friendly','outdoor','spiritual']]
    df2 = df1.set_index('city').T.to_dict('list')
    data = dict()
    names = []
    vectors = []

    for a,b in df2.items():
        names.append(a)
        vectors.append(b)

    data['name'] = np.array(names, dtype=object)
    data['vector'] = np.array(vectors, dtype=float)

    class AnnoyIndex():
        def __init__(self, vector, labels):
            self.dimention = vector.shape[1]
            self.vector = vector.astype('float32')
            self.labels = labels

        def build(self, number_of_trees=5): # test 5 **fix for now
            self.index = annoy.AnnoyIndex(self.dimention)
            for i, vec in enumerate(self.vector):
                self.index.add_item(i, vec.tolist())
            self.index.build(number_of_trees)
            
        def query(self, vector, k=10): # K  = 10 similarity match 95%
            indices = self.index.get_nns_by_vector(vector.tolist(), k)
            return [self.labels[i] for i in indices]
    index = AnnoyIndex(data["vector"], data["name"])
    index.build()

    place_set = []
    for x in input1:
        
        print(place_set)
        place_vector, place_name = data['vector'][list(data['name']).index(str(x))], data['name'][list(data['name']).index(str(x))]
        start = time.time()
        simlar_place_names = index.query(place_vector)
        print(f"The most similar places to {place_name} are {simlar_place_names}")
        # print(simlar_place_names)
        end = time.time()
        print(end - start)

        simlar_place_names.extend(place_set)
        print(place_set)
    place_set = list(set(place_set))
    
    
    my_dest = str(place_set)
    cities = []
    countries = []
    imgs = []
    descrs = []
    sights = []
    bts = []
    for i in simlar_place_names:
        # print(i)
        city = df[df['city']==str(i)]['city'].iloc[0]
        cities.append(city)
        cont = df[df['city']==str(i)]['country'].iloc[0]
        countries.append(cont)
        img = df[df['city']==str(i)]['img'].iloc[0]
        imgs.append(str(img))
        descr = df[df['city']==str(i)]['desc'].iloc[0]
        descrs.append(descr)
        sight = str(df[df['city']==str(i)]['sights'].iloc[0]).split(',')
        sights.append(sight)
        bt = df[df['city']==str(i)]['Best_time'].iloc[0]
        bts.append(bt)


    return render_template('sim_city.html',place_name = place_name,cities = cities,countries = countries, imgs=imgs,descrs = descrs,sights = sights,bts = bts)


@application.route('/about', methods = ['GET']) #About page route
def abouts():
    return render_template('about.html')

@application.route("/sim_user") #Associated user/city search route
def sim_user():
    if user_inputs is not None:
        try:
            # create the session
            conf = SparkConf()

            # create the context
            sc = pyspark.SparkContext(conf=conf)
            spark = SparkSession.builder \
            .config('spark.driver.memory','32G') \
            .config('spark.executor.memory=6g')\
            .config('spark.ui.showConsoleProgress', True) \
            .config('spark.sql.repl.eagerEval.enabled', True) \
            .config('spark.executor.cores','1')\
            .getOrCreate()



            df = spark.read.csv("nom_list.csv", header=False,).toDF('id','user','places')
            df=df.dropna()


            df2 = df.groupBy('user').agg(F.collect_set('places').alias('places'))

            fpGrowth = FPGrowth(itemsCol="places", minSupport=0.05, minConfidence=0.05)
            model = fpGrowth.fit(df2)

            df3 = spark.createDataFrame(
                [(1, "Abhi",str(user_inputs[0])),(2, "Abhi",str(user_inputs[1])),(3, "Abhi",str(user_inputs[2]))],["id", "user","places"])
            df4 = df3.groupBy('user').agg(F.collect_set('places').alias('places'))
            pred = model.transform(df4)
            result = pred.collect()
            result = result[0][2]
            result = [fix_text(str(i)) for i in result]
            spark.stop()

            return render_template('sim_user.html',result = result,p1 = str(user_inputs[0]),p2 = str(user_inputs[1]),p3 = str(user_inputs[2]))
        # return jsonify(result)
        except:
            try:
                sim_user()
            except:

                return render_template('test.html')
    else:
        # return render_template('test.html')
        return "bad data"


if __name__ == "__main__":
    application.run(debug = True,host="0.0.0.0")
