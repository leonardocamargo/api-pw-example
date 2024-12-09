import {expect, test} from '@playwright/test'
import path from 'path';
import fs from 'fs/promises'
const data = require('../../utils/data/post.json')


test.describe('api automation', () =>{

    test('get json with success', async ({request})=>{
        let start = Date.now()
        let response = await request.get('https://jsonplaceholder.typicode.com/users')
        let end = Date.now()

        let time = end - start 
        let convertedTime = time / 1000
        console.log(`execution time: ${convertedTime}s`)

        let responseBody = await response.json()

        console.log(responseBody)

        await expect(responseBody[0].id).toBe(1)
    })

    test('post with success', async ({request}) =>{

        let response = await request.post("https://jsonplaceholder.typicode.com/posts", {
            data: data
        })

        let responseBody = await response.json()

        console.log(responseBody)

    })
    test('get a new user ', async ({request}) =>{})

})

