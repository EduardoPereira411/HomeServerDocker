# Set up cron job to get size of custom directories
echo "Setting up cron jobs..."

CRON_SCRIPT_PATH="${HOME}/ContainerDBs/nodeExporter/GetDirSize.sh"
CRON_JOB="*/5 * * * * $CRON_SCRIPT_PATH"

if [ -f "$CRON_SCRIPT_PATH" ]; then
    chmod +x "$CRON_SCRIPT_PATH"
    
    (crontab -l 2>/dev/null | grep -Fq "$CRON_SCRIPT_PATH") && echo "Cron job already exists. Skipping." || {
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "Successfully added cron job for: $CRON_SCRIPT_PATH"
    }
else
    echo "Warning: $CRON_SCRIPT_PATH not found. Skipping cron setup for this file."
fi

echo "All tasks completed successfully."