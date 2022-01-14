const client = require('prom-client');
const express = require('express')

const register = client.register;
const app = express()
const port = 3000

const gauge = new client.Gauge({
    name: 'node_app_metrics_gauge',
    help: 'node_app_metrics_gauge_help',
});

const checkoutsTotal = new client.Counter({
    name: 'checkouts_total',
    help: 'Total number of checkouts',
    labelNames: ['payment_method']
})

const hellosProvided = new client.Counter({
    name: 'hellos_provided',
    help: 'Number of Hello World! strings provided.'
});

app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
})

app.get('/checkout', (req, res, next) => {
    const paymentMethod = Math.round(Math.random()) === 0 ? 'stripe' : 'paypal'

    checkoutsTotal.inc({
        payment_method: paymentMethod
    })

    res.json({ status: 'ok' })
    next()
})

app.get('/send-metrics', (req, res) => {

    let counter = 1

    const updateGauge = async () => {
        const randomValue = Math.floor(Math.random() * 100)
        const metrics = await register.metrics()
        console.log(metrics)

        if (randomValue % 2 === 1) {
            gauge.inc(randomValue);
            console.log(`+${randomValue}`)
            return
        }

        gauge.dec(randomValue);
        console.log(`-${randomValue}`)
    }

    const main = () => {
        setTimeout(() => updateGauge().then(
            () => {
                counter++
                if (counter < 10) {
                    console.log(counter)
                    main()
                    return
                }

                res.end("send 100 metrics")
            }
        ), 500)
    }


    main()

})

app.get('/', function(req, res){
    hellosProvided.inc()
    res.end("Add metrics hello provided + 1")
});


app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
})

process.on('SIGINT', function() {
    console.log( "\nGracefully shutting down from SIGINT (Ctrl-C)" );
    // some other closing procedures go here
    process.exit(1);
});



