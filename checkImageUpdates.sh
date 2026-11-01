for c in $(docker ps -q); do
    name=$(docker inspect --format='{{.Name}}' $c | sed 's/^\///')
    img=$(docker inspect --format='{{.Config.Image}}' $c)

    # Get the running container's local image ID
    running_id=$(docker inspect --format='{{.Image}}' $c)

    echo "--------------------------------------------------------"
    echo "Checking: $name ($img)"

    # Quietly pull the latest version from the registry
    if docker pull -q "$img" >/dev/null 2>&1; then
        # Get the new local image ID for this tag after pulling
        latest_id=$(docker inspect --format='{{.Id}}' "$img" 2>/dev/null)

        if [ "$running_id" != "$latest_id" ]; then
            echo " STATUS: UPDATE AVAILABLE"
            echo "   -> Running Image ID: ${running_id:7:12}"
            echo "   -> Latest Image ID:  ${latest_id:7:12}"
        else
            echo " STATUS: Up to date"
        fi
    else
        echo " STATUS: Error pulling image (private registry or network issue?)"
    fi
done
echo "--------------------------------------------------------"
