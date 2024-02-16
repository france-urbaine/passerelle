# Passerelle : how to deploy

Once you've got a deployable HEAD on main branch:

1. Tag a new Git version:

    ```shell
    git tag v1.0-beta.7
    ```

2. Push the tags to github remotes:

    ```shell
    git push origin --tags
    git push france_urbaine
    git push france_urbaine --tags
    ```

3. Draft a release on [Github](https://github.com/france-urbaine/passerelle/releases)

3. Update the APP_VERSION variable on CleverCloud:

    ```
    APP_VERSION="v1.0-beta.7"
    ```

4. Push main to CleverCloud:

    ```shell
    git push production main:master
    ```

5. Publish the drafted release on [Github](https://github.com/france-urbaine/passerelle/releases)
