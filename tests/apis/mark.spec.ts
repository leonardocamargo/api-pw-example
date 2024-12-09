import {test, expect} from '@playwright/test'

test.describe('login', ()=>{
    test('login with success', async ({page})=>{
        await page.goto('/login')
        await page.click('[placeholder="ahsahuauhs"]')
        await page.fill('[placeholder="ahsahuauhs"]',' marcos', {force: true})

    })
})