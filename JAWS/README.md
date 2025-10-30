# JAWS specific instructions

This needs a valid `JAWS.lic` file encrypted using GPG:

```sh
gpg --quiet --batch --yes --symmetric --passphrase="(the secret)" --output secret_JAWS.lic.gpg /path/to/unencrypted/JAWS.lic
```
