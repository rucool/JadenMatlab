These files are from the Data Analytics with MATLAB webinar found at:
http://www.mathworks.com/videos/data-analytics-with-matlab-99066.html

The files contain the data and code necessary to perform the historical data analysis.
To run everything you will need version R2014b or later and the following add-on products (along with what this demo uses them for):
- Curve Fitting Toolbox (for the smoothing spline)
- Statistics Toolbox (for the linear regression and decision tree models, and finding slope outliers)
- Neural Network Toolbox (for the neural network model)
- Signal Processing Toolbox (for the autocorrelation in the load signal)
- Parallel Computing Toolbox (optional but recommended for speeding parfor loops and model training)
Everything else in these files is done with just MATLAB.

The webinar also shows using the MATLAB Compiler, MATLAB Production Server and Amazon EC2, but these are not required for the historical data analysis performed in these files.

The primary script run from the webinar is the DataAnalyticsScript, which briefly summarizes the steps from the larger demo.

You can run the full demo by running Script1 through Script8 in order.

WARNING: Running scripts 1 & 4 will download and uncompress a large amount of data.

Script 1 will download approximately 60 MB of zip files that expand to about 400 MB.

Script 4 will download approximately 5 GB of zip files that expand to about 45 GB.

You can change the start and end dates in scripts 1 & 4 to download less data.

Running scripts 2 & 5 require first running scripts 1 & 4 respectively to download data.

You can skip running Script 1 & 2 by loading the results from nyiso_original.mat, and skip running Script 4 & 5 by loading weather_original.mat

Scripts 3, 6, 7 and 8 only load data from the included mat files and do not require downloading any data.

Copyright 2015 The MathWorks, Inc.