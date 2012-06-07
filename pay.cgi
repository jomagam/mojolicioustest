#!/usr/bin/perl
use strict;

#
# Sample script for Amazon FPS Singleuser
#

use CGI;
use lib '/home/ubuntu/amazon-fps-2010-08-28-perl-library/src';

use Data::Dumper;

use Amazon::CBUI::AmazonFPSSingleUsePipeline;
use Amazon::CBUI::AmazonFPSCBUIPipeline;
use Amazon::Utils::ReadConfig;
use Amazon::Utils::ConfigParams;
use Amazon::IpnReturnUrlValidation::SignatureUtilsForOutbound;


my $cgi = CGI->new;
my $urlEndPoint = "http://guineapigcode.com/cgi-bin/pay.cgi";

my $token = $cgi->param('tokenID');
if($token){
    my $parameters;
    foreach my $key (qw{expiry tokenID status callerReference signatureMethod signatureVersion certificateUrl signature}){
        $parameters->{$key} = $cgi->param($key);
    }
    
    my $correct;
    eval { $correct = Amazon::IpnReturnUrlValidation::SignatureUtilsForOutbound::validateRequest($parameters, $urlEndPoint, "GET")};
  
    my $message = $correct ? "PAYMENT VERIFIED" : "PAYMENT NOT VERIFIED: $@";

    $message .= "<pre>Data is:\n" . Dumper($parameters) . '</pre>';

    print "Content-type: text/html\n\n$message";
    exit;
}

my $amount = $cgi->param('amount');
my $reason = $cgi->param('reason');
unless($reason){
    $amount = int(rand(10_000))/100;
    $reason .= " (random amount)";
}

#Enter your accesskey and secret key below
my $accessKey = ReadConfig->get(ConfigParams->AwsAccessKey);
my $secretKey = ReadConfig->get(ConfigParams->AwsSecretKey);

AmazonFPSSingleUsePipeline::CommonMandatoryParameters($accessKey, $secretKey);

#Setting mandatory parameters for SingleUse
AmazonFPSSingleUsePipeline::setMandatoryParameters("callerReferenceSingleUse", $urlEndPoint, $amount);

#Add parameters optionally
AmazonFPSCBUIPipeline::addParameter("currencyCode", "USD");
AmazonFPSCBUIPipeline::addParameter("paymentReason", $reason);
AmazonFPSCBUIPipeline::addParameter("callerReference", 'ref-' . scalar time);

#Get the parameters hash array to validate
my %parameters = AmazonFPSCBUIPipeline::getParameters();
AmazonFPSSingleUsePipeline::validateParameters(%parameters);

my $redirect_url =  AmazonFPSCBUIPipeline::getUrl();

print "Location: $redirect_url\n\n";

