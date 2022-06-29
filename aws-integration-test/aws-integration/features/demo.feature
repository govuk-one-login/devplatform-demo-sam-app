Feature: demo
  Scenario: Process Audit Event
  Given I have an Event Handler deployed
  When  I invoke with an audit message "Hello World"
  Then  The audit message "Hello World" is emitted to a CloudWatch Log
  And   The audit message is written to an S3 Bucket

  Scenario: Put Records via Firehose
  Given I have an audit Firehose deployed
  When  I write the audit message "This is the Firehose" onto the Firehose
  Then  The audit message is written to an S3 Bucket