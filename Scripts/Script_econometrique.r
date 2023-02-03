#Partie ?conom?trique

######################## I - Nettoyage des donn?es #############################
#a - Importation du fichier csv
getwd()
setwd("../")
data <- read.csv("./Data/CSV/project_tmp.csv", header = TRUE, sep=",")
attach(data)

#Affichage des premi?res lignes
head(data)

#b - Cr?ation du dataframe en enlevant certaines dates et les variables de textes
df <- data.frame(id, status, ecMaxContribution, ecSignatureDate,
                 community = New_Community_Name, degree = Degree, 
                 nb_publication = Nb_Publication, project_duration = Project_Duration, 
                 nb_orga = Nb_Orga, nb_pays = country)

#c - Recodage de certaines variables
str(df)

#ecMaxContribution - conversion de "chr" en "num"
df$ecMaxContribution <- as.numeric(gsub(",", ".", df$ecMaxContribution)) 
which(is.na(df$ecMaxContribution))

#community - conversion de "int" en "facteur"
df$community <- as.factor(df$community)

#status - conversion de "char" en "facteur"
df$status <- as.factor(df$status)

#d - cr?ation de certaines variables
#publi_dummy - prends 1 s'il y a une publi, 0 sinon
df$publi_dummy <- ifelse(df$nb_publication == 0, 0, 1)


#status_dummy - prends 1 si SIGNED et 0 sinon, en regroupant TERMINATED et CLOSED
df$status_dummy <- ifelse(df$status == "SIGNED", 1, 0) 
df$status_dummy <- as.factor(df$status_dummy)

#e - Affichage de notre dataframe utilis?
attach(df)
head(df)
str(df)

################## II - Analyse de la variable cible nb_publication ############
summary(nb_publication)
boxplot(nb_publication)

#Test de v?rification des variables ab?rantes dans nb_publication par la m?thode des quartiles
#Cr?ation d'un nouveau dataframe test, en enlevant les id pour lesquels publi_dummy = 0
#Puis regarder la distribution
df_test <- subset(df, publi_dummy == 1)
summary(df_test$nb_publication)
boxplot(df_test$nb_publication)

Q1 <- quantile(df_test$nb_publication, 0.25)
Q3 <- quantile(df_test$nb_publication, 0.75)
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR
indices_outliers <- which(df_test$nb_publication < lower_bound | df_test$nb_publication > upper_bound)
outlier_ids <- df_test$id[indices_outliers]

df <- df[!(df$id %in% outlier_ids), ]
summary(df)
attach(df)

boxplot(nb_publication)

########### III - Analyse de la variable community ########
#M?thode de classification hi?rarchique
library(dplyr)
library(stats)

#matrice de distance entre les cat?gories
distance_matrix <- dist(table(community))
#classification hi?rarchique en utilisant la m?thode de liaison "ward.D2"
cluster_hierarchy <- hclust(distance_matrix, method = "ward.D2")
#coupe la classification pour obtenir 5 groupes
cut_cluster_hierarchy <- cutree(cluster_hierarchy, k = 5)
df <- df %>% mutate(grouped_community = cut_cluster_hierarchy[community])

head(df)
str(df)

#conversion
df$grouped_community <- as.factor(df$grouped_community)
attach(df)

############ IV - Analyse des donn?es + statistiques descriptives ##############
#1) Analyse globale
summary(df)

#2) Analyse univari?e 
########### PUBLI_DUMMY ##########
hist(publi_dummy,breaks = c(0,0.5,1))
table(publi_dummy)

########### NB_PAYS ############
summary(nb_pays)
boxplot(nb_pays)

########### DEGREE ############
summary(degree)
hist(degree)

########### STATUS_DUMMY ######
summary(status_dummy)
table(status_dummy)

########### GROUPED_COMMUNITY ######
summary(grouped_community)

#4) Analyse bivari?e 
#a - avec la fonction plot()
plot(nb_publication, degree)
plot(publi_dummy, degree)

#b - avec la fonction ggplot() du package ggplot2
library(ggplot2)
ggplot(df, aes(x=nb_orga, y=publi_dummy)) + geom_point()
ggplot(df, aes(x=nb_publication, y=nb_orga)) + geom_point()
ggplot(df, aes(x=nb_publication, y=nb_pays)) + geom_point()
ggplot(df, aes(x=community, y=nb_publication)) + geom_point()
ggplot(df, aes(x=community, y=publi_dummy)) + geom_point()

#c - table de contingence
table(nb_publication, status)
table(nb_publication, grouped_community)

#d - graphique de barres
ggplot(df, aes(x=factor(grouped_community), fill=factor(nb_publication))) + geom_bar(position="dodge")


#4) Matrices de corr?lations
#variables 2 ? 2
cor(nb_publication, ecMaxContribution)
cor(nb_publication, degree)
cor(nb_publication, project_duration)
cor(nb_publication, nb_orga)
cor(nb_publication, nb_pays)

library(corrplot)
corrplot(cor(df[c("nb_publication", "ecMaxContribution", "degree", 
                  "project_duration", "nb_orga", "nb_pays")]))

##################### III - Analyse ?conom?trique ##############################
#Objectif : analyser les facteurs explicatifs du nombre de publications par projet
#1 - Y = publi (s'il y a eu une publication ou pas)
#R?gression logit 
modele_glm <- glm(publi_dummy ~ status_dummy + ecMaxContribution + 
                    ecSignatureDate + grouped_community + degree + 
                    project_duration + nb_orga + nb_pays, data = df, 
                  family = binomial)

summary(modele_glm)

#2 - Y = Nombre de publications
#a - Regression linéaire 
modele <- lm(nb_publication ~ status_dummy + ecMaxContribution + 
             ecSignatureDate + grouped_community + degree + 
               project_duration + nb_orga + nb_pays, data = df)
summary(modele)

#b - Regression de Poisson
library(MASS)

modele_poisson <- glm(nb_publication ~ status_dummy + ecMaxContribution + 
                       ecSignatureDate + grouped_community + degree + 
                       project_duration + nb_orga + nb_pays, data = df, 
                      family = poisson)
summary(modele_poisson)

#c - Mod?le n?gatif binomial
modele_neg <- glm.nb(nb_publication ~ status_dummy + ecMaxContribution + 
                        ecSignatureDate + grouped_community + degree + 
                        project_duration + nb_orga + nb_pays, data = df)
summary(modele_neg)

##################### IV - Tests de robustesse ##############################

#Objectif : analyser l'évolution des résultats lors de la modifactions de la
# structure des modèles où des données

#1 - Y = publi (s'il y a eu une publication ou pas)
#Régression logit 
modele_probit <- glm(publi_dummy ~ status_dummy + ecMaxContribution + 
                    ecSignatureDate + grouped_community + degree + 
                    project_duration + nb_orga + nb_pays, data = df, 
                  binomial(link = probit))

summary(modele_probit)

modele_glm <- glm(publi_dummy ~ status_dummy + ecMaxContribution + 
                    ecSignatureDate + grouped_community + degree + 
                    project_duration + nb_orga + nb_pays + project_duration**2 +
                    degree**2 + nb_orga*nb_pays,
                  data = df, family = binomial)

summary(modele_glm)

#2 - Y = Nombre de publications
#a - Regression linéaire 
modele <- lm(nb_publication ~ status_dummy + ecMaxContribution + 
               ecSignatureDate + grouped_community + degree + 
               project_duration + nb_orga + nb_pays + project_duration**2 +
               degree**2 + nb_orga*nb_pays , data = df)
summary(modele)

#b - Regression de Poisson
library(MASS)

modele_poisson <- glm(nb_publication ~ status_dummy + ecMaxContribution + 
                        ecSignatureDate + grouped_community + degree + 
                        project_duration + nb_orga + nb_pays + project_duration**2 +
                        degree**2 + nb_orga*nb_pays, data = df, 
                      family = poisson)
summary(modele_poisson)

#c - Mod?le n?gatif binomial
modele_neg <- glm.nb(nb_publication ~ status_dummy + ecMaxContribution + 
                       ecSignatureDate + grouped_community + degree + 
                       project_duration + nb_orga + nb_pays + project_duration**2 +
                       degree**2 + nb_orga*nb_pays, data = df)
summary(modele_neg)

