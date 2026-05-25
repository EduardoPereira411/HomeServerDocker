#!/bin/bash
set -e

# Initialize env flag variable
USE_BACKUP_ENVS=false

# Check if the user passed the parameter to use backup env files
for arg in "$@"; do
    if [ "$arg" == "--use-envs" ] || [ "$arg" == "-e" ]; then
        USE_BACKUP_ENVS=true
    fi
done

# Define backup base directory
BACKUP_BASE_DIR="${HOME}/ContainerDBs/env_backups"

# Function to handle .env file linking if requested
link_env_file() {
    local target_dir=$1
    if [ "$USE_BACKUP_ENVS" = true ]; then
        
        # Check if this stack even requires an .env file by looking for EXAMPLE.env
        if [ -f "${target_dir}/EXAMPLE.env" ]; then
            local backup_env_path="${BACKUP_BASE_DIR}/${target_dir}/.env"
            
            if [ -f "$backup_env_path" ]; then
                echo "Linking backup .env for $target_dir"
                ln -sf "$backup_env_path" "${target_dir}/.env"
            else
                echo "Warning: Backup .env not found at $backup_env_path"
            fi
        # If no EXAMPLE.env exists skip check
        fi
        
    fi
}

ordered_stacks=(
    "Composes/Management/Portainer"
    "Composes/Networking/Adguard"
    "Composes/Networking/NginxReverseProxy"
)

echo "Starting high-priority stacks..."
for stack in "${ordered_stacks[@]}"; do
    if [ -d "$stack" ] && [ -f "$stack/docker-compose.yml" ]; then
        # Check and link env file if parameter matches
        link_env_file "$stack"

        echo "Deploying priority stack: $stack"
        (cd "$stack" && docker compose up -d)
        sleep 3 
    fi
done

echo "Starting remaining stacks..."
find . -name "docker-compose.yml" -type f | while read -r compose_file; do
    dir=$(dirname "$compose_file")
    clean_dir=${dir#./}
    
    # Check if this directory was already started in the priority phase
    skip=false
    for priority_stack in "${ordered_stacks[@]}"; do
        if [ "$clean_dir" == "$priority_stack" ]; then
            skip=true
            break
        fi
    done
    
    # If it wasn't started yet, deploy it now
    if [ "$skip" = false ]; then
        # Check and link env file if parameter matches
        link_env_file "$clean_dir"

        echo "Deploying stack: $clean_dir"
        (cd "$dir" && docker compose up -d)
    fi
done

echo "All stacks deployed successfully."