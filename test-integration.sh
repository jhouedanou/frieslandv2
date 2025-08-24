#!/bin/bash

echo "🧪 Test d'intégration Friesland Dashboard <-> Flutter"
echo "====================================================="

API_BASE_URL="http://localhost/api"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    local auth_header=$6

    echo -e "${BLUE}Test: ${description}${NC}"
    
    local curl_cmd="curl -s -w '%{http_code}' -X ${method}"
    
    if [ ! -z "$auth_header" ]; then
        curl_cmd="${curl_cmd} -H 'Authorization: Bearer ${auth_header}'"
    fi
    
    if [ ! -z "$data" ]; then
        curl_cmd="${curl_cmd} -H 'Content-Type: application/json' -d '${data}'"
    fi
    
    curl_cmd="${curl_cmd} ${API_BASE_URL}${endpoint}"
    
    local response=$(eval $curl_cmd)
    local status_code="${response: -3}"
    local body="${response%???}"
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "  ${GREEN}✅ PASS (${status_code})${NC}"
        if [ ! -z "$body" ] && [ "$body" != "null" ]; then
            echo "  Response: $(echo $body | head -c 100)..."
        fi
    else
        echo -e "  ${RED}❌ FAIL (attendu: ${expected_status}, reçu: ${status_code})${NC}"
        if [ ! -z "$body" ]; then
            echo "  Response: $body"
        fi
    fi
    echo ""
}

# Variables globales pour les tests
TOKEN=""
USER_ID=""

echo "🔍 Vérification de la disponibilité des services..."

# Test de santé de l'API
test_endpoint "GET" "/health" "" "200" "Health check de l'API"

# Test d'authentification
echo "🔐 Tests d'authentification..."
AUTH_DATA='{"email":"commercial@friesland.test","password":"password123","device_name":"test"}'
test_endpoint "POST" "/auth/login" "$AUTH_DATA" "200" "Connexion utilisateur"

# Extraire le token pour les tests suivants
echo "🎫 Récupération du token d'authentification..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE_URL/auth/login" \
  -H 'Content-Type: application/json' \
  -d "$AUTH_DATA")

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
    echo -e "${GREEN}✅ Token récupéré${NC}"
else
    echo -e "${RED}❌ Impossible de récupérer le token${NC}"
    exit 1
fi

echo ""
echo "🏢 Tests des PDVs..."
test_endpoint "GET" "/v1/pdvs" "" "200" "Liste des PDVs" "$TOKEN"
test_endpoint "GET" "/v1/pdvs/nearby?latitude=14.6937&longitude=-17.4441&radius=5" "" "200" "PDVs à proximité" "$TOKEN"

echo "📋 Tests des visites..."
test_endpoint "GET" "/v1/visites" "" "200" "Liste des visites" "$TOKEN"

echo "📊 Tests des analytics..."
test_endpoint "GET" "/v1/analytics/dashboard" "" "200" "Analytics dashboard" "$TOKEN"

echo "🌍 Tests des géofences..."
GEOFENCE_DATA='{"latitude":14.6937,"longitude":-17.4441}'
test_endpoint "POST" "/v1/geofences/check" "$GEOFENCE_DATA" "200" "Vérification géofence" "$TOKEN"

echo "📦 Tests des produits..."
test_endpoint "GET" "/v1/products" "" "200" "Liste des produits" "$TOKEN"
test_endpoint "GET" "/v1/products/categories" "" "200" "Catégories de produits" "$TOKEN"

echo "💰 Tests des prix..."
test_endpoint "GET" "/v1/prices/reference" "" "200" "Prix de référence" "$TOKEN"

echo "🔄 Tests de synchronisation..."
test_endpoint "GET" "/v1/sync/check" "" "200" "Vérification sync" "$TOKEN"

echo "👤 Tests utilisateur..."
test_endpoint "GET" "/v1/users/profile" "" "200" "Profil utilisateur" "$TOKEN"

echo "🧪 Test de création d'une visite..."
VISITE_DATA='{
  "pdv_id": "1",
  "commercial_id": "1",
  "date_visite": "'$(date -I)'",
  "statut": "planifiee",
  "notes": "Test d'\''intégration"
}'
test_endpoint "POST" "/v1/visites" "$VISITE_DATA" "201" "Création d'une visite" "$TOKEN"

echo "🏁 Tests de déconnexion..."
test_endpoint "POST" "/auth/logout" "" "200" "Déconnexion utilisateur" "$TOKEN"

echo ""
echo "====================================================="
echo "🎉 Tests d'intégration terminés!"
echo ""
echo "📋 Résumé des endpoints testés:"
echo "  - Authentification (login/logout)"
echo "  - Gestion des PDVs"
echo "  - Gestion des visites"  
echo "  - Analytics et rapports"
echo "  - Géofences"
echo "  - Produits et prix"
echo "  - Synchronisation"
echo "  - Profils utilisateurs"
echo ""
echo "🔧 Pour des tests plus poussés:"
echo "  - Utilisez Postman avec la collection générée"
echo "  - Testez l'app Flutter en mode développement"
echo "  - Vérifiez les logs: docker-compose logs -f dashboard"
echo "====================================================="