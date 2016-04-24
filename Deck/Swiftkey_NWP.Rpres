Swiftkey Next Word Prediction
========================================================
author: Nithya
date: April-2016

Executive Summary
========================================================

<style>
/* slide titles */
.reveal h3 { 
  font-size: 50px;
  color: blue;
}

.reveal { 
  font-size: 30px;
  color: grey;
}
</style>

Swiftkey who is the corporate partner in this capstone, builds a smart keyboard that makes it easier for people to type on their mobile devices. Our primary purpose of this capstone was to understand and build predictive text models like those used by SwiftKey.

We have used a rich data source (from blogs, news and twitter) and have done analysis to -

1. Discover the structure in the data and how words are put together (N-Grams)
2. Clean, Sample and Process the text data / N-Grams
3. Apply various smoothing techniques and Create a predictive Model
4. Deploy a Shiny App to put the model into use


Initial Analysis & Final Model
========================================================

<style>
/* slide titles */
.reveal h3 { 
  font-size: 50px;
  color: blue;
  
.reveal { 
  font-size: 30px;
  color: grey;
}
</style>

Below is the lexical variety of the Corpus. 

<div align="left">
<img src="Analysis.png" width=700 height=800>
</div>


***

Here is the Shiny App that deploys the final model - *https://nithsubr.shinyapps.io/Swiftkey_Analysis/*. <small><small>You must choose the smoothing algorithm - (Kenser Ney / Good Turing), enter some text in the input box and click on predict to see the predictions. Please try it.Its fairly simple!!</small></small>

<div align="left">
<img src="App.png" width=700 height=500>
</div>

Way to Next Word prediction Model
========================================================
<style>
/* slide titles */
.reveal h3 { 
  font-size: 50px;
  color: blue;
  
.reveal { 
  font-size: 30px;
  color: grey;  
}
</style>

Aim: To build a Next-Word-Prediction model that would predict 3 choices for the next word based on the text entered.
&nbsp;

**Techniques used to arrive at the final model**

1. Frequency Matrix was created for 1-Gram to 4-Grams

2. Kenser Ney smoothing with absolute discounting interpolation and Good Turing smoothing were deployed that can be used alternatively in the prediction model.

3. Finally Stupid Back-off was used for word prediction
&nbsp;

**Model Performance :**
The model now uses knowledge driven from 10% of initial Corpus, loads quickly and predicts fairly accurately with a speed less that 1 second.


2 Cents to share..
========================================================
<style>
/* slide titles */
.reveal h3 { 
  font-size: 50px;
  color: blue;
  
.reveal { 
  font-size: 30px;
  color: grey;  
}
</style>

From the Data Analysis and Model creation process, there have been several key take aways. Below were a few chappenges faced and how they were overcome - 

1. Data Volume : The size of the corpus was very large. But the preliminary data analysis suggested that taking 10% sample was sufficient to explain upto 85-90 % verbosity of the corpus. Thus random sampling of 10% of orginal size was done.

2. Performance : Inspite of sampling, performance was a bottleneck esp. when running the smoothing algorithms. The complex Smoothing algorithms were performed on SQL and interfaced with R

3. Shiny App : To reduce memory consumption and improve performance of the app, data tables were used and the words were stored as numbers

