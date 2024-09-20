import logging
import json
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="numOfVisits")
@app.route(route="process", auth_level=func.AuthLevel.ANONYMOUS)
@app.cosmos_db_input(arg_name="inputDocument", 
                     database_name="myPortfolioDb-vmc",
                     container_name = "visitorLogs-vmc",  
                     connection="AzureCosmosDBConnectionString",
                     )

@app.cosmos_db_output(arg_name="outputDocument", 
                      database_name="myPortfolioDb-vmc", 
                      container_name = "visitorLogs-vmc", 
                      connection="AzureCosmosDBConnectionString")

def main(req: func.HttpRequest, inputDocument: func.DocumentList, outputDocument: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Initialize the counter document object
    counter = {}

    if not inputDocument:
        # If the document doesn't exist, create a new one
        counter = {
            "id": "1",
            "count": 1
        }

        # Logging the initial data
        logging.info("INITIAL DATA JSON: %s", counter)

        outputDocument.set(func.Document.from_dict(counter))

        # Return the newly created document
        return func.HttpResponse(body=json.dumps(counter), status_code=201, headers={'content-type': 'application/json', 'charset': 'utf-8'})

    # Point counter document object to the incoming DB object
    elif inputDocument:
        counter = inputDocument[0].to_dict()

        # Increment the DB object count field by 1
        counter['count'] = counter.get('count', 0) + 1

        # Logging the return data
        logging.info("UPDATE DATA JSON: %s", counter)

        # Write to database. We use the outputDocument db object and set it to the incremented inputDocument object
        outputDocument.set(func.Document.from_dict(counter))

        # Return visitorCount
        return func.HttpResponse(body=json.dumps(counter), status_code=200, headers={'content-type': 'application/json', 'charset': 'utf-8'})
    else:
        return func.HttpResponse("Document not found", status_code=404)