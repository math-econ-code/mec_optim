 #
thePath = getwd()
# 
travelmodedataset = as.matrix(read.csv(paste0(thePath,"/travelmodedata.csv"),sep=",", header=TRUE)) # loads the data

convertmode = Vectorize ( 
  function(inputtxt) { 
    if (inputtxt == "air") {
      return(1) 
      }
    if (inputtxt == "train") {
      return(2)
      }
    if (inputtxt == "bus") {
      return(3)
      }
    if (inputtxt == "car") {
      return(4)
      }
  }
)

convertchoice = function(x) (ifelse(x=="no",0,1))

travelmodedataset[,2] = convertmode(travelmodedataset[,2])
travelmodedataset[,3] = convertchoice(travelmodedataset[,3])
nobs = dim(travelmodedataset)[1]
nind = nobs / 4
ncols =  dim(travelmodedataset)[2]
travelmodedataset = array(as.numeric(travelmodedataset),dim = c(4,nind,ncols))
choices = travelmodedataset[,,3]
s = apply(X = choices,FUN = mean, MARGIN = 1)
names(s)=c("air","train","bus","car")
print("Market shares:")
print(s)
# logit model
Ulogit = log(s[1:4]/s[4])
print("Systematic utilities (logit):")
print(Ulogit)
# nested logit model
# two nests = nocar,car
lambda = c(1/2,1/2)

Unocar = lambda[1]*log(s[1:3])+(1-lambda[1]) * log(sum(s[1:3]))
Ucar = lambda[2]*log(s[4])+(1-lambda[2]) * log(sum(s[4]))
Unested = c(Unocar,Ucar ) - Ucar
print("Systematic utilities (nested logit):")
print(Unested)

print("Choice probabilities within nocar nest (predicted vs observed):")
print( exp(Unested[1:3]/lambda[1]) / sum(exp(Unested[1:3]/lambda[1])))
print(s[1:3]/sum(s[1:3]))

print("Choice probabilities of car nest (predicted vs observed):")
print( 1 / (sum(exp(Unested[1:3]/lambda[1]))^lambda[1]+1) )
print(unname(s[4]))

