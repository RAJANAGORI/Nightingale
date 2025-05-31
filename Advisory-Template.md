# Nightingale Advisories

## <Month> - <Year>


## Third-Party Package Updates in Nightingale - Month 2025

Advisory ID: <br>
CVE ID:  Multiple <br>
Published: 2025-05-31 <br>
Last Update: 2025-05-31 <br>

### Description
We have addressed multiple CVEs originating from third-party dependencies in Nightingale versions 1.1.20 and above, across arm64 and amd64 architectures for Windows, Linux, and macOS platforms. The following vulnerabilities were resolved as part of this release:
		
| Package     | Remediation |     CVE      | Severity     |
| :---------- | :---------: | :----------: | :----------: |
| lib1 | Upgraded to v2.0 | Multiple<sub> *1*</sub>   | Critical  |
| lib2  | Removed  | Multiple<sub> *1*</sub>    | Critical   |

1. <em>Removed the packages when building Nightingale from base image - `ghcr.io/rajanagori/nightingale` to remedy CVE-2024-XXXX, CVE-2024-YYYY and CVE-2024-ZZZZZ </em>
<br><br>

### Solution
Upgrade Nightingale to versions 1.1.XX, or higher.
<br><br>

### Product Status
| Release Name | Base Version | Affected Versions | Fix Version |
| ----------   | :---------:  | :----------:     | :----------:|
| nightingale-go | 1.1 | 1.1.0 to 1.1.XX   | 1.1.YY  |
| nightingale-go | 1.0 | Affected   | Not Supported  |

### Severity
For the CVEs in this list, we adopted the severity rating that the vendor published.
