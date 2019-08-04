var cf = require('@mapbox/cloudfriend');

module.exports = {
AWSTemplateFormatVersion: '2010-09-09',
  Resources: {
    User: {
      Type: 'AWS::IAM::User',
      Properties: {
        Policies: [
          {
            PolicyName: 'List-objects-in-S3-bucket',
            PolicyDocument: {
              Statement: [
                {
                  Action: [
                    's3:GetObject',
                    's3:GetObjectAcl',
                    's3:ListBucket',
                    's3:ListAllMyBuckets'
                  ],
                  Effect: 'Allow',
                  Resource: [
                      'arn:aws:s3:::mapbox/*'
                  ],
                  Condition: {
                    StringLike: {
                      's3:prefix': '/vision/travis/ios-builds*'
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    },
    AccessKey: {
      Type: 'AWS::IAM::AccessKey',
      Properties: {
        UserName: cf.ref('User')
      }
    }
  },
  Outputs: {
    AccessKeyId: { Value: cf.ref('AccessKey') },
    SecretAccessKey: { Value: cf.getAtt('AccessKey', 'SecretAccessKey') }
  }
};

