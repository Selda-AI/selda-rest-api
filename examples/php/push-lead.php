<?php
/**
 * Push a lead into Selda from plain PHP. No library, no framework.
 *
 *   SELDA_API_KEY=sk_live_... SELDA_PROJECT_ID=... php push-lead.php
 */

function selda(string $path, string $fn, array $args): array {
	$ch = curl_init("https://api.selda.ai/mcp/$path");
	curl_setopt_array(
		$ch,
		array(
			CURLOPT_POST           => true,
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_HTTPHEADER     => array(
				'Authorization: Bearer ' . getenv( 'SELDA_API_KEY' ),
				'Content-Type: application/json',
			),
			CURLOPT_POSTFIELDS     => json_encode( array( 'fn' => $fn, 'args' => $args ) ),
		)
	);
	$body   = curl_exec( $ch );
	$status = curl_getinfo( $ch, CURLINFO_RESPONSE_CODE );
	curl_close( $ch );

	$decoded = json_decode( (string) $body, true );
	if ( $status >= 400 ) {
		// The refusal carries a reason. Read it before retrying: "too_many" is worth waiting out,
		// an address that asked Selda to stop is not.
		fwrite( STDERR, "Selda $status: $body\n" );
		exit( 1 );
	}
	return $decoded['value'];
}

$lead = selda(
	'mutate',
	'leads.add',
	array(
		'projectId'     => getenv( 'SELDA_PROJECT_ID' ),
		'company'       => 'Acme Oy',
		'email'         => 'owner@acme.fi',
		'companyDomain' => 'acme.fi',
		'source'        => 'my-app',
	)
);

echo ( $lead['duplicate'] ? 'Already known: ' : 'Added: ' ), $lead['leadId'], "\n";

// Nothing has been sent. Sending is a human press in the Selda app.
