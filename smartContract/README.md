# Tester le contrat sur remix 

- Rendez-vous sur https://remix.ethereum.org/
- Ajouter le contrat Voting.sol dans le dossier contracts de remix 
- Compiler Voting.sol dans solitdity compiler de remix
- Deployer et tester le contrat dans la rubrique Deploy and run transaction de remix


# Fonctionnalités de base 

- Celui qui déploie le contrat devient Owner du contrat
![Deploy](ressources/images/deploy.PNG)

- Inscription des électeurs : L'administrateur (Owner) peut inscrire les électeurs sur une liste blanche en utilisant leur adresse Ethereum.
![Register voter](ressources/images/registerVoter.PNG)

- Session d'enregistrement des propositions : L'administrateur peut démarrer une session d'enregistrement des propositions.
![Start proposal](ressources/images/StartProposal.PNG)

- Enregistrement des propositions : Les électeurs inscrits peuvent soumettre leurs propositions pendant la session d'enregistrement des propositions.
![Submit proposal](ressources/images/submitProposal.PNG)

- Clôture de la session d'enregistrement des propositions : L'administrateur peut mettre fin à la session d'enregistrement des propositions.
![End proposal](ressources/images/endProposal.PNG)

- Session de vote : L'administrateur peut lancer une session de vote.
![Start voting](ressources/images/startVoting.PNG)

- Consultation des propositions : Les électeurs peuvent consulter les propositions et leur ID qui seront nécesaires pour le vote (Par exemple, ici PHP : 0 , Java : 1)
![Get all proposals](ressources/images/getAllProposal.PNG)
  
- Vote : Les électeurs inscrits peuvent voter pour leurs propositions préférées. (avec l'id de la proposition donc ici l'électeur vote pour PHP)
![Vote](ressources/images/vote.PNG)

- Clôture de la session de vote : L'administrateur peut mettre fin à la session de vote.
![End Voting](ressources/images/endVoting.PNG)

- Comptabilisation des votes : L'administrateur peut comptabiliser les votes pour déterminer la proposition gagnante.
![Tally votes](ressources/images/tallyVote.PNG)

- Consultation des résultats : Tout le monde peut consulter la proposition gagnante (Son ID ou alors sa description).
![Winning proposal ID](ressources/images/winningProposalID.PNG)
![Winning proposal description](ressources/images/winningProposalDescription.PNG)

- Chaque votant peut consulter les votes des autres : On a l'adresse éthereum du votant , l'ID de la proposition pour laquelle l'électeur à voter et la date en timestamp. Evidemment le vote doit être terminé pour ne pas être influencé par les autres au moment de voter
![Vote history](ressources/images/voteHistory.PNG)

# Fonctionnalités BONUS

- Sujet de base : Le owner peut déterminer un sujet au contrat de vote
![Subject](ressources/images/subject.PNG)
  
- Retrait du droit de vote : L'administrateur peut retirer le droit de vote à un électeur.
![Revoke rights](ressources/images/revokeRights.PNG)

- Limitation des votes : Limite le nombre de propositions pour lesquelles un électeur peut voter, afin d'éviter des votes excessifs. Un électeur peut voter que pour 1 seule proposition.
![Error already vote](ressources/images/alreadyVote.PNG)

- Restriction de vote : Un électeur ne peut pas voter pour l'une de ses propres propositions. Cela permet d'éviter que tout le monde vote pour lui même
![Error vote for his own proposal](ressources/images/errorVoteForHisOwnProposal.PNG)

- Système de récompenses : La personne qui a soumis la proposition gagnante gagne 10 Voting token (VTK). Un token spécifique aux votes. On peut imaginer que l'organisation peut échanger ces tokens par la suite contre des avantages...
Pour cela j'ai crée un contract VotingToken
![Winner rewards](ressources/images/winnerRewards.PNG)

# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
