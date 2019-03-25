const fetch = require("node-fetch");
const {
    Aborter,
    BlobURL,
    BlockBlobURL,
    ContainerURL,
    ServiceURL,
    StorageURL,
    SharedKeyCredential,
    AnonymousCredential,
    TokenCredential,
    uploadStreamToBlockBlob
} = require("@azure/storage-blob");
const NOT_SET = "NOT_SET";

module.exports = async function(context, req) {
    context.log("JavaScript HTTP trigger function processed a request.");
    let error = checkParams();
    if (error.length > 0) {
        context.res = {
            status: 400,
            body: error
        };
        return;
    }

    const url = `https://consumption.azure.com/v3/enrollments/${
        process.env.ENROLLMENT_NUMBER
    }/usagedetails/download?billingPeriod=${req.params.period}`;

    const sharedKeyCredential = new SharedKeyCredential(
        process.env.BLOB_NAME,
        process.env.BLOB_KEY
    );
    const pipeline = StorageURL.newPipeline(sharedKeyCredential);
    const serviceURL = new ServiceURL(
        `https://${process.env.BLOB_NAME}.blob.core.windows.net`,
        pipeline
    );
    const containerURL = ContainerURL.fromServiceURL(
        serviceURL,
        process.env.CONTAINER_NAME
    );
    const blobURL = BlobURL.fromContainerURL(containerURL, req.params.period);
    const blockBlobURL = BlockBlobURL.fromBlobURL(blobURL);

    const options = {
        method: "GET",
        headers: { Authorization: `Bearer ${process.env.API_KEY}` }
    };
    context.log("fetching:", url);

    try {
        response = await fetch(url, options);
        await uploadStreamToBlockBlob(
            Aborter.timeout(30 * 60 * 60 * 1000), // Abort uploading with timeout in 30mins
            response.body,
            blockBlobURL,
            4 * 1024 * 1024,
            20,
            {
                progress: ev => console.log(ev)
            }
        );
        //text = response.text();
        context.res = {
            body: `Usage for billing period: ${
                req.params.period
            } successfully downloaded`
        };
    } catch (err) {
        context.res = {
            status: 400,
            body: `The following error occurred: ${err}`
        };
    }
};

checkParams = function() {
    let errorMessages = [];
    [
        "API_KEY",
        "ENROLLMENT_NUMBER",
        "BLOB_CONNECTION_STRING",
        "BLOB_KEY",
        "BLOB_NAME",
        "CONTAINER_NAME"
    ].map((value, index, array) => {
        console.log(value);
        if ((process.env[value] || NOT_SET) === NOT_SET) {
            errorMessages.push("Please define environment variable:" + value);
        }
    });
    return errorMessages;
};
