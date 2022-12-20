import json

source = "../Data/Raw/h2020_Projects/project.json"
fichier = open(source, "r", encoding="utf8")
contenu = fichier.read()
fichier.close()
projets = json.loads(contenu)
print("\n")
print(projets[0].keys())
liste_des_champs = ['acronym', 'contentUpdateDate', 'ecMaxContribution', 'ecSignatureDate', 'endDate', 'frameworkProgramme', 'fundingScheme', 'grantDoi', 'id', 'legalBasis', 'masterCall', 'nature', 'objective', 'rcn', 'startDate', 'status', 'subCall', 'title', 'topics', 'totalCost']
liste_des_champs_a_afficher = ['acronym',  'ecMaxContribution',  'id',   'status', 'title', 'totalCost']

# for projet in projets:
    # print(f'{projet["acronym"]:<20}',f'{projet["status"]:<10}',f'{projet["totalCost"]:<10}')
print("\nprojet 1st element")
print(projets[0])

source2 = "../Data/Raw/h2020_Projects/organization.json"
fichier = open(source2, "r", encoding="utf8")
contenu = fichier.read()
fichier.close()
organizations = json.loads(contenu)
print()
print(organizations[0].keys())

source3 = "../Data/Raw/h2020_Publications/projectPublications.json"
fichier = open(source3, "r", encoding="utf8")
contenu = fichier.read()
fichier.close()
publications = json.loads(contenu)
print(f"\nNumber of publications: {len(publications)}")

