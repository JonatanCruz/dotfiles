# ==============================================================================
# GCLOUD - Aliases para Google Cloud CLI
# ==============================================================================

# Comando base
alias g='gcloud'

# ==============================================================================
# AUTENTICACIÓN Y CONFIGURACIÓN
# ==============================================================================

alias gauth='gcloud auth login'
alias gauthlist='gcloud auth list'
alias grevoke='gcloud auth revoke'
alias gconfig='gcloud config list'
alias gconfigs='gcloud config configurations list'
alias gconfigactivate='gcloud config configurations activate'
alias gconfigcreate='gcloud config configurations create'

# Configurar proyecto
alias gproject='gcloud config set project'
alias gprojectlist='gcloud projects list'

# Configurar región y zona
alias gregion='gcloud config set compute/region'
alias gzone='gcloud config set compute/zone'

# ==============================================================================
# COMPUTE ENGINE (VM INSTANCES)
# ==============================================================================

# Listar y gestionar instancias
alias gvm='gcloud compute instances'
alias gvmlist='gcloud compute instances list'
alias gvmcreate='gcloud compute instances create'
alias gvmdelete='gcloud compute instances delete'
alias gvmstart='gcloud compute instances start'
alias gvmstop='gcloud compute instances stop'
alias gvmreset='gcloud compute instances reset'
alias gvmdescribe='gcloud compute instances describe'

# SSH a instancias
alias gssh='gcloud compute ssh'
alias gscp='gcloud compute scp'

# Machine types y disks
alias gmachines='gcloud compute machine-types list'
alias gdisks='gcloud compute disks list'

# ==============================================================================
# KUBERNETES ENGINE (GKE)
# ==============================================================================

alias gke='gcloud container'
alias gkelist='gcloud container clusters list'
alias gkecreate='gcloud container clusters create'
alias gkedelete='gcloud container clusters delete'
alias gkedescribe='gcloud container clusters describe'
alias gkeresize='gcloud container clusters resize'

# Obtener credenciales de kubectl
alias gkecreds='gcloud container clusters get-credentials'

# Listar node pools
alias gkenodes='gcloud container node-pools list'

# ==============================================================================
# CLOUD RUN
# ==============================================================================

alias grun='gcloud run'
alias grunlist='gcloud run services list'
alias grundeploy='gcloud run deploy'
alias grundelete='gcloud run services delete'
alias grundescribe='gcloud run services describe'
alias grunlogs='gcloud run services logs read'

# ==============================================================================
# CLOUD FUNCTIONS
# ==============================================================================

alias gfunc='gcloud functions'
alias gfunclist='gcloud functions list'
alias gfuncdeploy='gcloud functions deploy'
alias gfuncdelete='gcloud functions delete'
alias gfuncdescribe='gcloud functions describe'
alias gfunclogs='gcloud functions logs read'

# ==============================================================================
# APP ENGINE
# ==============================================================================

alias gapp='gcloud app'
alias gappdeploy='gcloud app deploy'
alias gappversions='gcloud app versions list'
alias gappservices='gcloud app services list'
alias gappbrowse='gcloud app browse'
alias gapplogs='gcloud app logs tail'

# ==============================================================================
# CLOUD SQL
# ==============================================================================

alias gsql='gcloud sql'
alias gsqllist='gcloud sql instances list'
alias gsqlcreate='gcloud sql instances create'
alias gsqldelete='gcloud sql instances delete'
alias gsqldescribe='gcloud sql instances describe'
alias gsqlconnect='gcloud sql connect'

# Bases de datos
alias gsqldbs='gcloud sql databases list'
alias gsqldbcreate='gcloud sql databases create'

# ==============================================================================
# CLOUD STORAGE (GCS)
# ==============================================================================

alias gstorage='gcloud storage'
alias gls='gcloud storage ls'
alias gcp='gcloud storage cp'
alias gmv='gcloud storage mv'
alias grm='gcloud storage rm'
alias gmkdir='gcloud storage buckets create'

# Listar buckets
alias gbuckets='gcloud storage buckets list'
alias gbucketdescribe='gcloud storage buckets describe'

# ==============================================================================
# IAM (Identity and Access Management)
# ==============================================================================

alias giam='gcloud iam'
alias gserviceaccounts='gcloud iam service-accounts list'
alias gsamake='gcloud iam service-accounts create'
alias gsakeys='gcloud iam service-accounts keys list'
alias gsakey='gcloud iam service-accounts keys create'

# Políticas y roles
alias groles='gcloud iam roles list'
alias gpolicy='gcloud projects get-iam-policy'

# ==============================================================================
# CLOUD BUILD
# ==============================================================================

alias gbuild='gcloud builds'
alias gbuildlist='gcloud builds list'
alias gbuildsubmit='gcloud builds submit'
alias gbuildlogs='gcloud builds log'

# ==============================================================================
# LOGGING Y MONITORING
# ==============================================================================

alias glogs='gcloud logging'
alias glogsread='gcloud logging read'
alias glogstail='gcloud logging tail'

# ==============================================================================
# SERVICIOS Y APIS
# ==============================================================================

alias gservices='gcloud services list'
alias gserviceenable='gcloud services enable'
alias gservicedisable='gcloud services disable'

# ==============================================================================
# REDES (NETWORKING)
# ==============================================================================

alias gnetworks='gcloud compute networks list'
alias gsubnets='gcloud compute networks subnets list'
alias gfirewall='gcloud compute firewall-rules list'
alias gfwcreate='gcloud compute firewall-rules create'
alias gfwdelete='gcloud compute firewall-rules delete'

# IPs y balanceadores
alias gips='gcloud compute addresses list'
alias glbs='gcloud compute forwarding-rules list'

# ==============================================================================
# ARTIFACT REGISTRY & CONTAINER REGISTRY
# ==============================================================================

alias gar='gcloud artifacts'
alias garlist='gcloud artifacts repositories list'
alias garcreate='gcloud artifacts repositories create'

alias gcr='gcloud container images'
alias gcrlist='gcloud container images list'

# ==============================================================================
# INFORMACIÓN Y AYUDA
# ==============================================================================

alias ginfo='gcloud info'
alias gversion='gcloud version'
alias ghelp='gcloud help'
alias gcomponents='gcloud components list'

# ==============================================================================
# FUNCIONES ÚTILES
# ==============================================================================

# Cambiar de proyecto rápidamente
gswitch() {
    if [ -z "$1" ]; then
        echo "Uso: gswitch <project-id>"
        echo "Proyectos disponibles:"
        gcloud projects list --format="table(projectId)"
    else
        gcloud config set project "$1"
        echo "✓ Proyecto cambiado a: $1"
    fi
}

# SSH a una instancia por nombre (busca automáticamente)
gvmssh() {
    if [ -z "$1" ]; then
        echo "Uso: gvmssh <instance-name> [zone]"
        echo "Instancias disponibles:"
        gcloud compute instances list --format="table(name,zone,status)"
    else
        local zone="${2:-$(gcloud compute instances list --filter="name=$1" --format="value(zone)" | head -1)}"
        if [ -n "$zone" ]; then
            gcloud compute ssh "$1" --zone="$zone"
        else
            echo "Error: No se encontró la instancia '$1'"
        fi
    fi
}

# Ver logs recientes de Cloud Run
grunlogs-tail() {
    if [ -z "$1" ]; then
        echo "Uso: grunlogs-tail <service-name>"
        echo "Servicios disponibles:"
        gcloud run services list --format="table(metadata.name,status.url)"
    else
        gcloud run services logs read "$1" --limit=50 --format=json | jq -r '.textPayload // .jsonPayload | tostring'
    fi
}

# Desplegar a Cloud Run con configuraciones comunes
grun-deploy() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Uso: grun-deploy <service-name> <image-url> [region]"
        echo "Ejemplo: grun-deploy my-service gcr.io/my-project/my-image:latest us-central1"
    else
        local region="${3:-us-central1}"
        gcloud run deploy "$1" \
            --image "$2" \
            --platform managed \
            --region "$region" \
            --allow-unauthenticated
    fi
}

# Ver todas las configuraciones activas
gcontext() {
    echo "=== Configuración Actual ==="
    echo "Proyecto:  $(gcloud config get-value project 2>/dev/null)"
    echo "Account:   $(gcloud config get-value account 2>/dev/null)"
    echo "Región:    $(gcloud config get-value compute/region 2>/dev/null)"
    echo "Zona:      $(gcloud config get-value compute/zone 2>/dev/null)"
    echo "Config:    $(gcloud config configurations list --filter=is_active:true --format='value(name)' 2>/dev/null)"
}

# Listar recursos principales del proyecto actual
gresources() {
    local project=$(gcloud config get-value project 2>/dev/null)
    echo "=== Recursos en proyecto: $project ==="
    echo ""
    echo "--- Compute Engine VMs ---"
    gcloud compute instances list --format="table(name,zone,machineType,status)" 2>/dev/null || echo "No hay instancias"
    echo ""
    echo "--- GKE Clusters ---"
    gcloud container clusters list --format="table(name,location,status)" 2>/dev/null || echo "No hay clusters"
    echo ""
    echo "--- Cloud Run Services ---"
    gcloud run services list --format="table(metadata.name,status.url,status.traffic[0].latestRevision)" 2>/dev/null || echo "No hay servicios"
    echo ""
    echo "--- Cloud Storage Buckets ---"
    gcloud storage buckets list --format="table(name,location,storageClass)" 2>/dev/null | head -10
}

# Limpiar recursos de un proyecto (con confirmación)
gcleanup() {
    local project=$(gcloud config get-value project 2>/dev/null)
    echo "⚠️  Esto eliminará TODOS los recursos del proyecto: $project"
    echo "¿Estás seguro? (escribe 'yes' para confirmar)"
    read confirmation
    if [ "$confirmation" = "yes" ]; then
        echo "Eliminando instancias..."
        gcloud compute instances list --format="value(name,zone)" | while read name zone; do
            gcloud compute instances delete "$name" --zone="$zone" --quiet
        done
        echo "✓ Limpieza completada"
    else
        echo "Operación cancelada"
    fi
}
