#!/bin/bash

prenom=""
Theme_actuel=""
numero_theme=""
minimum=60

barre_chargement() {
    echo -n "🐧Chargement : ["
    for i in {1..25}; do
        echo -n "#"
        sleep 0.1  
    done
    echo "] Terminé! 🐧" 
} 

notif() 
{
(
 local message=$1 
 local couleur="\e[5;31m" 
 local reset="\e[0m"
 echo -ne "\e[s\e[40G${couleur}$message${reset}\e[u"
 sleep 5
 local espaces=$(printf "%${#message}s" "")
 echo -ne "\e[s\e[40G${espaces}\e[u" 
) &
}

fic()
{
	echo "MasterLin/progression_${prenom}.txt" ;
}

#natao ity ho an'ny joueur vao nanomboka
#ny niveau 1 rehetra misokatra avec ratio 0 et les autres sont verrouillés
init_progression() 
{
    local fichier
    fichier=$(fic)

    # Ne créer que si le fichier n'existe pas encore
    #theme_niveau=ratio ---> Io no format repère an'ny progression
    if [ ! -f "$fichier" ]; then
    	touch $fichier
        cat > "$fichier" <<EOF
gestion_niveau1=0
gestion_niveau2=verrou      
gestion_niveau3=verrou
texte_niveau1=0
texte_niveau2=verrou
texte_niveau3=verrou
droits_niveau1=0
droits_niveau2=verrou
droits_niveau3=verrou
EOF
        # Protection : seul le propriétaire peut lire/écrire
        chmod 600 "$fichier"
    fi
}

lire_score() 
{
	#fampiasana an'io fonction io: lire_score "theme" "niveau" ary @ debloque_niv no ampiasana
	#mamaky anle ao aorian'ny '=' ao am fichier progression
	local theme=$1    
	local niv=$2 
	local repere="${theme}_${niv}"
	local fichier
	fichier=$(fic)
	#afin d'extraire le ratio après '='
	grep "^${repere}=" "$fichier" | cut -d'=' -f2
}

sauver_score() 
{
	#sauver_score "theme" "niveau" "ratio"
	#manova ny ratio ho ratio vaovao
	local theme=$1
	local niv=$2
	local ratio=$3
	local repere="${theme}_${niv}"
	local fichier
	fichier=$(fic)
	sed -i "s/^${repere}=.*/${repere}=${ratio}/g" "$fichier"
}

debloque_niv()
{
#debloque_niv "theme" "niv_actuel" "ratio"
local theme=$1
local niv_actuel=$2
local ratio=$3
local fichier
fichier=$(fic)
local niv_suivant=""
	if   [ "$niv_actuel" = "niveau1" ]; then niv_suivant="niveau2"
	elif [ "$niv_actuel" = "niveau2" ]; then niv_suivant="niveau3"
	fi
	
	if [ -n "$niv_suivant" ] && [ "$ratio" -ge "$minimum" ]; then
        	local repere_suivant="${theme}_${niv_suivant}"
        	local score_suivant
        	score_suivant=$(lire_score "$theme" "$niv_suivant")
        
        	if [ "$score_suivant" = "verrou" ]; then
            		sed -i "s/^${repere_suivant}=verrou/${repere_suivant}=0/" "$fichier"
            		echo ""
            		echo "🔓 Niveau débloqué : $niv_suivant !"
            		sleep 2
            	fi
        fi
}

theme_repere() 
{
if   [ "$numero_theme" = "1" ]; then echo "gestion"
elif [ "$numero_theme" = "2" ]; then echo "texte"
elif [ "$numero_theme" = "3" ]; then echo "droits"
fi
}

# Afficher la progression d'un thème dans le menu niveau (voir menu niveau pour plus de comprehension)
afficher_progress_niveau() 
{
local repere
repere=$(theme_repere)
local s1 s2 s3

s1=$(lire_score "$repere" "niveau1")
s2=$(lire_score "$repere" "niveau2")
s3=$(lire_score "$repere" "niveau3")

local affiche1 affiche2 affiche3

	if [ "$s1" = "verrou" ]; then affiche1="🔒 Verrouillé"
	else affiche1="🔓 Meilleur score : ${s1}%"
	fi

	if [ "$s2" = "verrou" ]; then affiche2="🔒 Verrouillé (besoin ${minimum}% au niveau 1)"
	else affiche2="🔓 Meilleur score : ${s2}%"
	fi

	if [ "$s3" = "verrou" ]; then affiche3="🔒 Verrouillé (besoin ${minimum}% au niveau 2)"
	else affiche3="🔓 Meilleur score : ${s3}%"
	fi

	echo "[1] Niveau 1  —  $affiche1"
	echo "[2] Niveau 2  —  $affiche2"
	echo "[3] Niveau 3  —  $affiche3"
}

accueil()
{
echo "================================"
echo "      ****MasterLin****      "
echo " "
echo " Quizz et apprentissage amusant "
echo " "
echo "--------------------------------"

if [ ! -d MasterLin ]; then
    mkdir MasterLin
    touch MasterLin/password.txt
    chmod 600 MasterLin/password.txt
fi

echo "Entrer votre prénom:"
read prenom

if grep -q "^$prenom:" MasterLin/password.txt ; then
    echo -n "Joueur existant. Entrer le mot de passe: "
    read -s mot_de_passe	
    echo ""
    
    saisi=$(echo -n "$mot_de_passe" | sha256sum | cut -d' ' -f1)
    stocke=$(grep "^$prenom:" MasterLin/password.txt | cut -d ':' -f2)
    
   while [ "$saisi" != "$stocke" ]; do
        echo "Mot de passe incorrect. Réessayer: "
        read -s mot_de_passe
        echo ""
        saisi=$(echo -n "$mot_de_passe" | sha256sum | cut -d' ' -f1)
    done
    
    echo "Rebonjour $prenom !"
else
    echo "Nouveau joueur. Entrez votre mot de passe:"
    read -s mot_de_passe
    echo ""
    pwd_hash=$(echo -n "$mot_de_passe" | sha256sum | cut -d ' ' -f1)
    echo "$prenom:$pwd_hash" >> MasterLin/password.txt
    echo "Hello $prenom ! Are you ready ?"
fi

init_progression

barre_chargement 
sleep 1
}

menu_principal()
{
    while true; do
        clear
        echo -e "\a" 
        notif "Entrer le numéro correspondant à votre choix"
        echo "================================"
        echo "      ****MasterLin****      "
        echo "================================"
        echo "	[1] Jouer solo"
        echo "	[2] Mode Assistance"
        echo "	[3] A propos"	
        echo "	[4] Historique"	
        echo "	[5] Quitter"
        echo "Entrez votre choix:"
        read choix
    
        while [ -z "$choix" ]; do
            echo "Redéfinissez votre choix"
            read choix
        done

        while [ "$choix" != '1' -a "$choix" != '2' -a "$choix" != '3' -a "$choix" != '4' -a "$choix" != '5' ]; do
            echo "Redéfinissez votre choix"
            read choix
        done

        if [ "$choix" = '1' ]; then
            clear
            modules
            
        elif [ "$choix" = '2' ];then
        	clear
        	echo "Mode Assistane EN COURS DE FANAMBOARANA"
        	sleep 2
    
        elif [ "$choix" = '3' ]; then
            clear
            echo "=======❓A propos❓======"
            echo "	------------------------------------------"
            echo "	|MasterLin — Jeu de quiz Linux           |"
            echo "	|3 modules : fichiers, texte, permissions|"
            echo "	|3 niveaux par module                    |"
            echo "	|Questions aléatoires a chaque partie    |"
            echo "	|#en cours# mode assistance et duel      |"
            echo "	-----------------------------------------"
            echo "Appuyez sur Entree pour revenir..."
            read

        elif [ "$choix" = '4' ]; then
            clear
            echo "====HISTORIQUE===="
            echo ""
            if [ -f MasterLin/historique.txt ]; then
                cat MasterLin/historique.txt
            else
                echo "Pas de scores pour le moment"
            fi
            echo ""
            echo "Appuyer sur Entree pour revenir"
            read
            
        elif [ "$choix" = '5' ]; then
            echo "See you 👋"
            sleep 2
            exit 0
        fi
    done
}

modules()
{
    while true; do
        clear
        notif "Entrer le numéro correspondant à votre choix"
        echo ""	
        echo "=====THEMES====="
        echo "~~~~~📁💬🔏~~~~~"
        echo ""
        echo "[1] Gestion de fichiers"
        echo "[2] Traitements de texte"
        echo "[3] Droits et permissions"
        echo "[4] Retour"
        echo "Entrez votre choix: "
        read module_choix

        while [ -z "$module_choix" ]; do
            echo "Redéfinissez votre choix"
            read module_choix
        done
        
        while [ "$module_choix" != '1' -a "$module_choix" != '2' -a "$module_choix" != '3' -a "$module_choix" != '4' ]; do
            echo "Redéfinissez votre choix"
            read module_choix
        done

        if [ "$module_choix" = '1' ]; then
            Theme_actuel="Gestion de fichiers"
            numero_theme=1
            niveau
        elif [ "$module_choix" = '2' ]; then
            Theme_actuel="Traitement de texte"
            numero_theme=2
            niveau
        elif [ "$module_choix" = '3' ]; then
            Theme_actuel="Droits et permissions"
            numero_theme=3
            niveau
        elif [ "$module_choix" = '4' ]; then
            return
        fi
    done
}

niveau()
{
    clear
    notif "Entrer le numéro correspondant à votre choix"
    echo "🐧=======NIVEAU=======🐧"
    echo "Thème: $Theme_actuel"
    echo " "
    afficher_progress_niveau
    echo "[4] Retour"
    echo ""
    read op

    while [ -z "$op" ]; do
        echo "Redéfinissez votre choix"
        read op
    done

    while [ "$op" != '1' -a "$op" != '2' -a "$op" != '3' -a "$op" != '4' ]; do
        echo "Redéfinissez votre choix"
        read op 
    done
    
    if [ "$op" = '4' ]; then
        return
    fi

    #verifier na si le niveau est débloqué ou non
    local repere
    repere=$(theme_repere)
    local niv_choisi=""
    
    if   [ "$op" = '1' ]; then niv_choisi="niveau1"
    elif [ "$op" = '2' ]; then niv_choisi="niveau2"
    elif [ "$op" = '3' ]; then niv_choisi="niveau3"
    fi
    
    
    local score_actuel
    score_actuel=$(lire_score "$repere" "$niv_choisi")
    
    #Si verouillé alors refuser l'accès et expliquer
    if [ "$score_actuel" = "verrou" ]; then
    	echo " Ce niveau est verouillé 🔒 "
    	
    	if [ "$niv_choisi" = "niveau2" ]; then
	    local s1
            s1=$(lire_score "$repere" "niveau1")
            echo "   Terminez le niveau 1 avec au moins ${minimum}%"
            echo "   Votre meilleur score niveau 1 : ${s1}%"
    	elif [ "$niv_choisi" = "niveau3" ]; then
            local s2
            s2=$(lire_score "$repere" "niveau2")
            echo "   Terminez le niveau 2 avec au moins ${minimum}%"
            echo "   Votre meilleur score niveau 2 : ${s2}%"
        fi  
        
        sleep 3
        niveau #re afficher le meni niveau
        return
     fi
    
    	if [ "$op" = '1' ]; then
    	    echo "on va y aller doucement☺️"
    	    barre_chargement
    	    sleep 2
    	    quizz "niveau1"

    	elif [ "$op" = '2' ]; then
    	    echo "Tu peux le faire💪"
    	    barre_chargement
    	    sleep 2
    	    quizz "niveau2"
        
    	elif [ "$op" = '3' ]; then
    	    echo "HAAH! on devient expert🔥"
    	    barre_chargement
    	    sleep 2
    	    quizz "niveau3"
        
   	fi
}

quizz()
{
    clear
    notif "Bonne chance !"
    local niveau=$1
    local fichier_question=""
    local score=0
    local total=5
    local numeroquest=1

    # ✅ CORRECTION 1 : sélection du bon fichier selon niveau
    if [ "$niveau" = "niveau1" ]; then
        fichier_question="questions/facile${numero_theme}.csv"
    elif [ "$niveau" = "niveau2" ]; then
        fichier_question="questions/moyen${numero_theme}.csv"
    elif [ "$niveau" = "niveau3" ]; then
        fichier_question="questions/difficile${numero_theme}.csv"
    fi

    if [ ! -f "$fichier_question" ]; then
        echo "Fichier questions introuvable : $fichier_question"
        sleep 3
        return
    fi

    echo "+++++++++QUIZZ++++++++"
    echo "Thème: $Theme_actuel"
    echo "Niveau: $niveau"
    echo "______________________"
    sleep 2

    # ✅ CORRECTION 2 : IFS='|' sans espace — lecture correcte des champs
    # ✅ CORRECTION 3 : variable 'ligne' remplacée par les vraies variables lues
    while IFS='|' read -r question C1 C2 C3 C4 bonne; do

        # Ignorer lignes vides ou commentaires (filtre de sécurité)
        [ -z "$question" ] && continue
        [[ "$question" == \#* ]] && continue

        # ✅ CORRECTION 4 : nettoyage des espaces et \r parasites sur TOUS les champs
        question=$(echo "$question" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        C1=$(echo "$C1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        C2=$(echo "$C2" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        C3=$(echo "$C3" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        C4=$(echo "$C4" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        bonne=$(echo "$bonne" | tr -d '[:space:]\r')

        clear
        echo "=== Question $numeroquest/$total ==="
        echo "Thème : $Theme_actuel"
        echo "Score : $score"
        echo ""
        echo " $question"
        echo ""
        echo "  [1] $C1"
        echo "  [2] $C2"
        echo "  [3] $C3"
        echo "  [4] $C4"
        echo ""
        echo -n "Votre réponse? (1-4) : "
        read reponse < /dev/tty

        while [ "$reponse" != '1' -a "$reponse" != '2' -a "$reponse" != '3' -a "$reponse" != '4' ]; do
            echo "Option invalide"
            sleep 1
            echo -n "Votre réponse? (1-4) : "
            read reponse < /dev/tty
        done

        if [ "$reponse" = "$bonne" ]; then
            echo ""
            echo "✅ Bonne réponse ! +1 point"
            notif "Bien joué !"
            score=$((score + 1))
        else
            local texte_bonne=""
            if [ "$bonne" = "1" ]; then texte_bonne="$C1"
            elif [ "$bonne" = "2" ]; then texte_bonne="$C2"
            elif [ "$bonne" = "3" ]; then texte_bonne="$C3"
            elif [ "$bonne" = "4" ]; then texte_bonne="$C4"
            fi
            echo ""
            echo "❌ Mauvaise réponse."
            echo "La bonne réponse était : $texte_bonne"
            notif "Pas de chance !"
        fi

        numeroquest=$((numeroquest + 1))
        sleep 3

    # ✅ CORRECTION 5 : pipeline propre — grep filtre, shuf mélange, head limite à $total
    done < <(grep -v '^#' "$fichier_question" | grep -v '^[[:space:]]*$' | shuf | head -n $total)

    resultat "$score" "$total" "$niveau"
}

resultat()
{
    local score_final=$1
    local total_questions=$2
    local niveau_affiche=$3
    
    clear
    echo "==================="
    echo "   FIN DU NIVEAU   "
    echo "==================="
    echo ""
    echo "Thème : $Theme_actuel"
    echo "Niveau : $niveau_affiche"
    echo ""
    echo "Score final : $score_final / $total_questions"
    echo ""

    # Message selon performance
    local ratio=$((score_final * 100 / total_questions))
    if [ "$ratio" -ge 80 ]; then
        echo "🏆 Excellent ! Tu maîtrises ce niveau !"
    elif [ "$ratio" -ge "$minimum" ]; then
        echo "👍 Pas mal ! Continue à t'entraîner, tu as ttteint le seuil de déblocage du niveau suivant."
    else
        echo "💪 Courage ! Réessaie pour t'améliorer, il faut ${minimum}% pour débloquer le niveau suivant!"
    fi
    
    local repere
    repere=$(theme_repere) #manova ny numero_theme ho nom du theme
    
    local ancien
    ancien=$(lire_score "$repere" "$niveau_affiche")
    
	if [ "$ancien" != "verrou" ] && [ "$ancien" -ge "$ratio" ] 2>/dev/null; then
        	echo ""
        	echo "Meilleur score conservé : ${ancien}% (actuel : ${ratio}%)"
	else
        	# Nouveau meilleur score => sauvegarder
        	sauver_score "$repere" "$niveau_affiche" "$ratio"
        	echo ""
        	echo "Nouveau meilleur score : ${ratio}%"
        fi
        
    #deblocage niveau suivant raha mahatratra ny seuil ou min=60%    
    debloque_niv "$repere" "$niveau_affiche" "$ratio"

    echo "$(date '+%d/%m/%Y %H:%M') | $prenom | $Theme_actuel | $niveau_affiche | $ratio" >> MasterLin/historique.txt
    
    echo ""
    echo "Appuyer sur Entrer pour revenir"
    read
}

accueil
menu_principal
