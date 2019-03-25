# azure-cost-management
Starter project to setup bespoke cost management tools

As many of the people I work with struggle with their finops, I wanted to create a simple - yet powerfull - way to automate the way to fetch usage data from their Enterprise Agreement Enrollments.
After All we're in the cloud, and everything is just a matter of a few lines of code.

## Concept
I decided to setup an azure function to fetch usage data billing period by billing period. The resulting CSV files are then stored in a BLOB container where you can do whatever you like ;-). For instance, I implemented a small PowerBI report that fetches all the blob files and renders teh data as charts and filters

## Pre-requisites
This starter projects is a simple BASH script. You therefore need a BASH capable terminal. For our friends Windows lovers, you can use your Windows Bash or the azure cloud shell. The benefits of using azure cloud shell are numerous, and among them:
- no need to setup azure CLI
- always up to date
- pretty fast to fire up

To start a cloud shell just type the following URL in your favorite browser : http://shell.azure.com

Second, this project relies on the [Azure Functions Core Tools](https://github.com/Azure/azure-functions-core-tools). PLease refer tho the documentation to have them installed before you continue! Usually a simple npm is enough:
```npm i -g azure-functions-core-tools```

**WARNING** Be careful Azure Cloud Shell users! Cloud Shell does not allow you to install outside of your $HOME folder. Still, you can use Azure Functions Core Tools, but you'll have an extra setup step : be sure to be at the top of your $HOME hierarchy and type the following:

```
npm i azure-functions-core-tools
export PATH=$PATH:~/node_modules/.bin
```

## Installation
1- clone this repo : 

``` git clone https://github.com/pierreg256/azure-cost-management.git``` 

2- Change dierrctory to the cloned repo and start the configuration process:

```
cd azure-cost-management
./configure.sh
```

