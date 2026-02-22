extends Label

var level_titles = {
	0: "Incident Type: Distributed Denial of Service (DDoS) Attacks",
	1: "Incident Type: Malware - Virus Infections",
	2: "Incident Type: Social Engineering - Phishing Attacks",
	3: "Incident Type: Malware - Trojan Horse Infections",
	4: "Incident Type: SQL Injection Vulnerabilities"
}

func set_level_title(level: int) -> void:
	if level_titles.has(level):
		text = level_titles[level]
	else:
		text = "Unknown Level"
