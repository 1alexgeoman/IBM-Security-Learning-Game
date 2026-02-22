extends Label

const threat_summaries: Array[String]= [
	# round 0 DDOS
	"A high-volume Distributed Denial of Service (DDoS) attack was detected targeting our main system servers. The attack flooded the network with excessive traffic from thousands of IP addresses, overwhelming system resources and slowing down critical operations.",
	# round 1 Virus
	"A virus infected a senior worker's computer and began to spread through an internal email. Although the attack was detected early it spread quickly through a bug in our email application that caused the file to download even without it being selected by a user.",
	# round 2 Phishing
	"Fake emails from the CDSO were sent to internal emails. The attack was unsuccessful however it shows a critical issue with our mail system accepting all external emails.",
	# round 3 Trojan
	"Software downloaded from an irreputable source led to malware that avoided normal scan detection. The software when used by the employees mimicked it's legitemate counterpart.",
	# round 4 SQL Injection
	"Read and write operations that were not part of usual operation began to occur. It was found that the requests included embedded sql commands that were executed as normal SQL."
]

func _ready() -> void:
	text= threat_summaries[GameManager.current_round]
