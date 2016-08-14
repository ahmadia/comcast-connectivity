until ./test.py; do
    echo "test.py crashed with exit code $?.  Respawning.." >&2
    sleep 1
done
