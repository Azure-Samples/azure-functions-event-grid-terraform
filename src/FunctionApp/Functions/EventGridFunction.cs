using System;
using System.Threading.Tasks;
using Microsoft.Azure.EventGrid.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Sample.FunctionApp.Functions
{
    public class EventGridFunction
    {
        [FunctionName(nameof(StorageHandler))]
        public async Task StorageHandler(
            [EventGridTrigger] EventGridEvent[] eventGridEvents,
            [EventGrid(TopicEndpointUri = @"SAMPLE_TOPIC_END_POINT", TopicKeySetting = @"SAMPLE_TOPIC_KEY")] IAsyncCollector<EventGridEvent> outputEvents,
            ILogger logger)
        {
            if (eventGridEvents == null)
            {
                throw new ArgumentNullException("Null request received");
            }

            foreach (var ege in eventGridEvents)
            {
                logger.LogTrace($@"Got event grid message: {JsonConvert.SerializeObject(ege, Formatting.Indented)}");

                ege.Topic = null;   // have to reset topic for the message send to work
                ege.DataVersion = "1"; // required to be set

                await outputEvents.AddAsync(ege);

                logger.LogTrace($@"Sent to output topic. {JsonConvert.SerializeObject(ege, Formatting.Indented)}");
            }
        }
    }
}