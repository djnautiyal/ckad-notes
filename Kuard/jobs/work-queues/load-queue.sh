# create a work queue called 'keygen'
curl -X PUT http://localhost:8080/memq/server/queues/keygen

# Create 100 work items and load up the queue
for i in work-item-{0..99}; do
  curl -X POST http://localhost:8080/memq/server/queues/keygen/enqueue -d "$i"
done