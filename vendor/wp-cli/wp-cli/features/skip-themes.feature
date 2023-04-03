Feature: Skipping themes

  @require-wp-4.7
  Scenario: Skipping themes via global flag
    Given a WP installation
    # Themes will already be installed on WP core trunk.
    And I try `wp theme install twentysixteen`
    And I try `wp theme install twentyseventeen --activate`

    When I run `wp eval 'var_export( function_exists( "twentyseventeen_body_classes" ) );'`
    Then STDOUT should be:
      """
      true
      """
    And STDERR should be empty

    # The specified theme should be skipped
    When I run `wp --skip-themes=twentyseventeen eval 'var_export( function_exists( "twentyseventeen_body_classes" ) );'`
    Then STDOUT should be:
      """
      false
      """
    And STDERR should be empty

    # All themes should be skipped
    When I run `wp --skip-themes eval 'var_export( function_exists( "twentyseventeen_body_classes" ) );'`
    Then STDOUT should be:
      """
      false
      """
    And STDERR should be empty

    # Skip another theme
    When I run `wp --skip-themes=twentysixteen eval 'var_export( function_exists( "twentyseventeen_body_classes" ) );'`
    Then STDOUT should be:
      """
      true
      """
    And STDERR should be empty

    # The specified theme should still show up as an active theme
    When I run `wp --skip-themes theme status twentyseventeen`
    Then STDOUT should contain:
      """
      Active
      """
    And STDERR should be empty

    # Skip several themes
    When I run `wp --skip-themes=twentysixteen,twentyseventeen eval 'var_export( function_exists( "twentyseventeen_body_classes" ) );'`
    Then STDOUT should be:
      """
      false
      """
    And STDERR should be empty

  Scenario: Skip parent and child themes
    Given a WP installation
    And I run `wp theme install moina moina-blog`

    When I run `wp theme activate moina`
    When I run `wp eval 'var_export( function_exists( "moina_setup" ) );'`
    Then STDOUT should be:
      """
      true
      """

    When I run `wp --skip-themes=moina eval 'var_export( function_exists( "moina_setup" ) );'`
    Then STDOUT should be:
      """
      false
      """
    And STDERR should be empty


    When I run `wp theme activate moina-blog`
    When I run `wp eval 'var_export( function_exists( "moina_setup" ) );'`
    Then STDOUT should be:
      """
      true
      """

    When I run `wp eval 'var_export( function_exists( "moina_blog_scripts" ) );'`
    Then STDOUT should be:
      """
      true
      """

    When I run `wp --skip-themes=moina-blog eval 'var_export( function_exists( "moina_setup" ) );'`
    Then STDOUT should be:
      """
      false
      """
    And STDERR should be empty

    When I run `wp --skip-themes=moina-blog eval 'var_export( function_exists( "moina_blog_scripts" ) );'`
    Then STDOUT should be:
      """
      false
      """
    And STDERR should be empty

    When I run `wp --skip-themes=moina-blog eval 'echo get_template_directory();'`
    Then STDOUT should contain:
      """
      wp-content/themes/moina
      """
    And STDERR should be empty

    When I run `wp --skip-themes=moina-blog eval 'echo get_stylesheet_directory();'`
    Then STDOUT should contain:
      """
      wp-content/themes/moina-blog
      """
    And STDERR should be empty

  Scenario: Skipping multiple themes via config file
    Given a WP installation
    And a wp-cli.yml file:
      """
      skip-themes:
        - classic
        - default
      """
    And I run `wp theme install classic --activate`
    And I run `wp theme install default`

    # The classic theme should show up as an active theme
    When I run `wp theme status`
    Then STDOUT should contain:
      """
      A classic
      """
    And STDERR should be empty

    # The default theme should show up as an installed theme
    When I run `wp theme status`
    Then STDOUT should contain:
      """
      I default
      """
    And STDERR should be empty

    And I run `wp theme activate default`

    # The default theme should be skipped
    When I run `wp eval 'var_export( function_exists( "kubrick_head" ) );'`
    Then STDOUT should be:
      """
      false
      """
    And STDERR should be empty
