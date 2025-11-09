const { test, expect } = require('@playwright/test');

test.describe('Tests de parcours du catalogue', () => {

  test('Test 6: Parcours du catalogue et visualisation de produit - Cas passant ✅', async ({ page }) => {
    // Naviguer vers la page d'accueil
    await page.goto('/');
    
    // Cliquer sur la catégorie Books
    await page.locator('a[href="/books"]').click();
    
    // Vérifier que nous sommes sur la page Books
    await expect(page).toHaveURL(/.*books/);
    await expect(page.locator('.page-title h1')).toContainText('Books');
    
    // Vérifier qu'il y a des produits affichés
    const productItems = page.locator('.product-item');
    const productCount = await productItems.count();
    
    expect(productCount).toBeGreaterThan(0);
    console.log(`✅ Nombre de produits trouvés dans Books: ${productCount}`);
    
    // Récupérer le titre du premier produit
    const firstProductTitle = await page.locator('.product-item:first-child .product-title a').textContent();
    console.log(`Premier produit: ${firstProductTitle}`);
    
    // Cliquer sur le premier produit
    await page.locator('.product-item:first-child .product-title a').click();
    
    // Attendre le chargement de la page de détails
    await page.waitForLoadState('networkidle');
    
    // Vérifier que la page de détails s'affiche correctement
    await expect(page.locator('.product-name')).toBeVisible();
    await expect(page.locator('.product-name')).toContainText(firstProductTitle.trim());
    
    // Vérifier la présence des éléments clés
    await expect(page.locator('.price-value-18')).toBeVisible();
    await expect(page.locator('input[value="Add to cart"]')).toBeVisible();
    
    // Vérifier qu'il y a une description
    const descriptionExists = await page.locator('.full-description, .short-description').count();
    expect(descriptionExists).toBeGreaterThan(0);
    
    console.log('✅ Page de détails du produit affichée correctement');
  });

  test('Test 6 bis: Navigation entre plusieurs catégories - Cas passant ✅', async ({ page }) => {
    await page.goto('/');
    
    // Tester la catégorie Computers
    await page.locator('a[href="/computers"]').click();
    await expect(page).toHaveURL(/.*computers/);
    await expect(page.locator('.page-title h1')).toContainText('Computers');
    
    // Aller dans la sous-catégorie Desktops
    await page.locator('a[href="/desktops"]').click();
    await expect(page).toHaveURL(/.*desktops/);
    
    const desktopProducts = await page.locator('.product-item').count();
    expect(desktopProducts).toBeGreaterThan(0);
    console.log(`✅ ${desktopProducts} ordinateurs de bureau trouvés`);
    
    // Tester la catégorie Electronics
    await page.goto('/');
    await page.locator('a[href="/electronics"]').click();
    await expect(page).toHaveURL(/.*electronics/);
    await expect(page.locator('.page-title h1')).toContainText('Electronics');
    
    const electronicsProducts = await page.locator('.product-item').count();
    expect(electronicsProducts).toBeGreaterThan(0);
    console.log(`✅ ${electronicsProducts} produits électroniques trouvés`);
  });

  test('Test 6 ter: Recherche de produits - Cas passant ✅', async ({ page }) => {
    await page.goto('/');
    
    // Utiliser la barre de recherche
    await page.locator('input#small-searchterms').fill('computer');
    await page.locator('.button-1.search-box-button').click();
    
    // Vérifier les résultats de recherche
    await page.waitForLoadState('networkidle');
    
    const searchResults = await page.locator('.product-item').count();
    expect(searchResults).toBeGreaterThan(0);
    
    console.log(`✅ Recherche "computer" a retourné ${searchResults} résultats`);
    
    // Vérifier que les résultats contiennent le terme recherché
    const firstResult = await page.locator('.product-item:first-child .product-title').textContent();
    console.log(`Premier résultat: ${firstResult}`);
  });
});
