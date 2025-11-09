const { test, expect } = require('@playwright/test');
const { createAccount, login, clearCart, wait } = require('../utils/helpers');

test.describe('Tests de passage de commande', () => {
  let testUser;

  test.beforeAll(async ({ browser }) => {
    // Créer un compte pour les tests de commande
    const context = await browser.newContext();
    const page = await context.newPage();
    testUser = await createAccount(page);
    await context.close();
    console.log(`✅ Compte créé pour les tests de commande: ${testUser.email}`);
  });

  test.beforeEach(async ({ page }) => {
    // Se connecter et vider le panier avant chaque test
    await login(page, testUser.email, testUser.password);
    await clearCart(page);
  });

  test('Test 10: Passage de commande complet - Cas passant ✅', async ({ page }) => {
    // Ajouter un produit au panier
    await page.goto('/books');
    const productName = await page.locator('.product-item:first-child .product-title a').textContent();
    console.log(`Commande du produit: ${productName}`);
    
    await page.locator('.product-item:first-child input[value="Add to cart"]').click();
    await wait(2000);
    
    // Aller au panier
    await page.goto('/cart');
    
    // Vérifier que le produit est dans le panier
    await expect(page.locator('.cart-item-row')).toBeVisible();
    
    // Accepter les conditions de service
    await page.locator('input#termsofservice').check();
    
    // Cliquer sur Checkout
    await page.locator('button#checkout').click();
    
    // Page Billing Address
    await page.waitForURL(/.*checkout\/onepagecheckout/);
    console.log('✅ Page de checkout chargée');
    
    // Remplir l'adresse de facturation
    await page.locator('select#BillingNewAddress_CountryId').selectOption('France');
    await wait(500); // Attendre le chargement des villes
    
    await page.locator('input#BillingNewAddress_City').fill('Paris');
    await page.locator('input#BillingNewAddress_Address1').fill('123 Rue de Test');
    await page.locator('input#BillingNewAddress_ZipPostalCode').fill('75001');
    await page.locator('input#BillingNewAddress_PhoneNumber').fill('0123456789');
    
    // Cliquer sur Continue (Billing)
    await page.locator('#billing-buttons-container input[value="Continue"]').click();
    await wait(1000);
    
    // Page Shipping Address - utiliser la même adresse
    await page.locator('#shipping-buttons-container input[value="Continue"]').click();
    await wait(1000);
    
    // Page Shipping Method - sélectionner Ground
    await page.locator('input#shippingoption_0').check();
    await page.locator('#shipping-method-buttons-container input[value="Continue"]').click();
    await wait(1000);
    
    // Page Payment Method - sélectionner Cash On Delivery
    await page.locator('input#paymentmethod_0').check();
    await page.locator('#payment-method-buttons-container input[value="Continue"]').click();
    await wait(1000);
    
    // Page Payment Information
    await page.locator('#payment-info-buttons-container input[value="Continue"]').click();
    await wait(1000);
    
    // Page Confirm Order - vérifier le récapitulatif
    await expect(page.locator('.product-name')).toContainText(productName.trim());
    
    // Confirmer la commande
    await page.locator('#confirm-order-buttons-container input[value="Confirm"]').click();
    
    // Attendre la page de confirmation
    await page.waitForURL(/.*checkout\/completed/);
    
    // Vérifier le message de succès
    await expect(page.locator('.title')).toContainText('Your order has been successfully processed!');
    
    // Récupérer le numéro de commande
    const orderNumberText = await page.locator('.details li:first-child').textContent();
    console.log(`✅ Commande confirmée: ${orderNumberText}`);
    
    // Vérifier la présence du lien vers les détails
    await expect(page.locator('a[href*="/orderdetails/"]')).toBeVisible();
    
    // Vérifier que le panier est vide
    await page.locator('a.ico-cart').click();
    const cartCount = await page.locator('.cart-qty').textContent();
    expect(cartCount).toContain('(0)');
    
    console.log('✅ Commande complète réussie et panier vidé');
  });

  test('Test 10 bis: Tentative de checkout sans accepter les conditions - Cas non passant ❌', async ({ page }) => {
    // Ajouter un produit au panier
    await page.goto('/books');
    await page.locator('.product-item:first-child input[value="Add to cart"]').click();
    await wait(2000);
    
    // Aller au panier
    await page.goto('/cart');
    
    // NE PAS cocher les conditions de service
    // await page.locator('input#termsofservice').check();
    
    // Tenter de cliquer sur Checkout
    await page.locator('button#checkout').click();
    
    // Attendre un message d'alerte ou vérifier qu'on reste sur la page du panier
    await wait(500);
    
    // Écouter les alertes JavaScript
    page.on('dialog', async dialog => {
      expect(dialog.message()).toContain('agree');
      await dialog.accept();
      console.log('✅ Alerte détectée: conditions non acceptées');
    });
    
    // Vérifier qu'on est toujours sur la page du panier
    await expect(page).toHaveURL(/.*cart/);
    
    console.log('✅ Le système empêche le checkout sans accepter les conditions');
  });

  test('Test 10 ter: Commande avec plusieurs produits - Cas passant ✅', async ({ page }) => {
    // Ajouter plusieurs produits
    await page.goto('/books');
    await page.locator('.product-item:nth-child(1) input[value="Add to cart"]').click();
    await wait(1000);
    await page.locator('.product-item:nth-child(2) input[value="Add to cart"]').click();
    await wait(1000);
    
    // Aller au panier
    await page.goto('/cart');
    
    // Vérifier qu'il y a 2 produits
    const cartItems = await page.locator('.cart-item-row').count();
    expect(cartItems).toBe(2);
    
    // Récupérer le total
    const totalText = await page.locator('.order-total strong').textContent();
    console.log(`Total de la commande: ${totalText}`);
    
    // Accepter les conditions et procéder au checkout
    await page.locator('input#termsofservice').check();
    await page.locator('button#checkout').click();
    
    await page.waitForURL(/.*checkout/);
    
    // Processus de checkout simplifié (on sait que ça fonctionne)
    await page.locator('select#BillingNewAddress_CountryId').selectOption('France');
    await wait(500);
    await page.locator('input#BillingNewAddress_City').fill('Lyon');
    await page.locator('input#BillingNewAddress_Address1').fill('456 Avenue Test');
    await page.locator('input#BillingNewAddress_ZipPostalCode').fill('69001');
    await page.locator('input#BillingNewAddress_PhoneNumber').fill('0987654321');
    
    await page.locator('#billing-buttons-container input[value="Continue"]').click();
    await wait(1000);
    await page.locator('#shipping-buttons-container input[value="Continue"]').click();
    await wait(1000);
    await page.locator('input#shippingoption_0').check();
    await page.locator('#shipping-method-buttons-container input[value="Continue"]').click();
    await wait(1000);
    await page.locator('input#paymentmethod_0').check();
    await page.locator('#payment-method-buttons-container input[value="Continue"]').click();
    await wait(1000);
    await page.locator('#payment-info-buttons-container input[value="Continue"]').click();
    await wait(1000);
    
    // Vérifier que les 2 produits sont dans le récapitulatif
    const confirmItems = await page.locator('.product-name').count();
    expect(confirmItems).toBe(2);
    
    await page.locator('#confirm-order-buttons-container input[value="Confirm"]').click();
    await page.waitForURL(/.*checkout\/completed/);
    
    await expect(page.locator('.title')).toContainText('Your order has been successfully processed!');
    
    console.log('✅ Commande avec plusieurs produits réussie');
  });
});
